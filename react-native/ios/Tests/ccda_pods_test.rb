require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../ccda_pods'

class CCDAPodsTest < Minitest::Test
  def setup
    @directory = Dir.mktmpdir('ccda-pods-test')
    @project = Xcodeproj::Project.new(File.join(@directory, 'Pods', 'Pods.xcodeproj'))
    @bridge = @project.new_target(:static_library, 'ccda-kit-react-native', :ios, '16.0')
    @app = @project.new_target(:application, 'Host', :ios, '16.0')
    @installer = Struct.new(:pods_project).new(@project)
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_published_engine_is_pinned_and_linked_only_to_bridge
    2.times { ccda_post_install(@installer) }
    @project.save
    project = Xcodeproj::Project.open(@project.path)
    before = project.to_hash
    ccda_post_install(Struct.new(:pods_project).new(project))
    assert_equal before, project.to_hash
    reference = project.root_object.package_references.fetch(0)
    assert_equal 1, project.root_object.package_references.size
    assert_equal 'https://github.com/ccda-tools/ccda-swift.git', reference.repositoryURL
    version = JSON.parse(File.read(File.expand_path('../../package.json', __dir__))).fetch('version')
    assert_equal({ 'kind' => 'exactVersion', 'version' => version }, reference.requirement)
    bridge = project.targets.find { |target| target.name == @bridge.name }
    assert_equal 1, bridge.package_product_dependencies.size
    product = bridge.package_product_dependencies.first
    assert_equal 'CCDAEngine', product.product_name
    assert_equal reference, product.package
    assert_equal 1, bridge.frameworks_build_phase.files.count { |file| file.product_ref == product }
    bridge.build_configurations.each do |configuration|
      assert_equal ['$(inherited)', '$(PODS_CONFIGURATION_BUILD_DIR)'], Shellwords.split(configuration.build_settings['SWIFT_INCLUDE_PATHS'])
    end
    assert_empty project.targets.find { |target| target.name == @app.name }.package_product_dependencies
  end

  def test_local_engine_path_is_relative_to_generated_project
    path = local_engine_path
    2.times { ccda_post_install(@installer, engine_path: path) }
    assert_equal 1, @project.root_object.package_references.size
    reference = @project.root_object.package_references.first
    assert_equal 'XCLocalSwiftPackageReference', reference.isa
    assert_equal '../apple', reference.relative_path
    assert_equal reference, @bridge.package_product_dependencies.first.package
  end

  def test_explicit_published_version_updates_existing_reference
    ccda_post_install(@installer)
    ccda_post_install(@installer, engine_version: '1.0.0')
    assert_equal 1, @project.root_object.package_references.size
    assert_equal({ 'kind' => 'exactVersion', 'version' => '1.0.0' }, @project.root_object.package_references.first.requirement)
    assert_equal 1, @bridge.package_product_dependencies.size
  end

  def test_invalid_published_version_fails_before_modifying_project
    assert_raises(RuntimeError) { ccda_post_install(@installer, engine_version: 'latest') }
    assert_empty @project.root_object.package_references
  end

  def test_switching_source_does_not_leave_duplicate_products_or_packages
    ccda_post_install(@installer, engine_path: local_engine_path)
    ccda_post_install(@installer)
    assert_equal 1, @project.root_object.package_references.size
    assert_equal 'XCRemoteSwiftPackageReference', @project.root_object.package_references.first.isa
    assert_equal 1, @bridge.package_product_dependencies.size
    assert_equal 1, @bridge.frameworks_build_phase.files.size
    ccda_post_install(@installer, engine_path: local_engine_path)
    assert_equal 1, @project.root_object.package_references.size
    assert_equal 'XCLocalSwiftPackageReference', @project.root_object.package_references.first.isa
    assert_equal 1, @bridge.package_product_dependencies.size
    assert_equal 1, @bridge.frameworks_build_phase.files.size
  end

  def test_switching_source_preserves_packages_still_used_by_other_targets
    ccda_post_install(@installer, engine_path: local_engine_path)
    local_reference = @project.root_object.package_references.first
    other_product = @project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
    other_product.product_name = 'CCDAUI'
    other_product.package = local_reference
    @app.package_product_dependencies << other_product
    ccda_post_install(@installer)
    assert_includes @project.root_object.package_references, local_reference
    assert_equal local_reference, @app.package_product_dependencies.first.package
    assert_equal 'XCRemoteSwiftPackageReference', @bridge.package_product_dependencies.first.package.isa
  end

  def test_preserves_host_search_paths_and_unrelated_packages
    @bridge.build_configurations.each { |configuration| configuration.build_settings['SWIFT_INCLUDE_PATHS'] = ['$(inherited)', '/host/modules'] }
    unrelated = @project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
    unrelated.repositoryURL = 'https://example.com/another-package.git'
    unrelated.requirement = { 'kind' => 'exactVersion', 'version' => '1.0.0' }
    @project.root_object.package_references << unrelated
    2.times { ccda_post_install(@installer) }
    assert_includes @project.root_object.package_references, unrelated
    @bridge.build_configurations.each do |configuration|
      assert_equal ['$(inherited)', '/host/modules', '$(PODS_CONFIGURATION_BUILD_DIR)'], configuration.build_settings['SWIFT_INCLUDE_PATHS']
    end
  end

  def test_missing_bridge_reports_actionable_error
    @bridge.remove_from_project
    assert_match(/autolinking/, assert_raises(RuntimeError) { ccda_post_install(@installer) }.message)
  end

  def test_missing_local_manifest_fails_before_modifying_project
    assert_raises(RuntimeError) { ccda_post_install(@installer, engine_path: File.join(@directory, 'missing')) }
    assert_empty @project.root_object.package_references
  end

  private

  def local_engine_path
    path = File.join(@directory, 'apple')
    FileUtils.mkdir_p(path)
    File.write(File.join(path, 'Package.swift'), '// Synthetic package manifest for project wiring tests.\n')
    path
  end
end
