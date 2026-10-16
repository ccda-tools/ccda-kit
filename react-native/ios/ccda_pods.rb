require 'json'
require 'pathname'
require 'shellwords'
require 'xcodeproj'

# Call after react_native_post_install. CocoaPods saves the project afterwards.
# Published hosts default to the matching release. Local source requires an
# explicit override supplied by a development host, never path auto-detection.
def ccda_post_install(installer, engine_version: nil, engine_path: nil)
  project = installer.pods_project
  bridge = project.targets.find { |target| target.name == 'ccda-kit-react-native' }
  raise 'ccda-kit-react-native pod target was not found; enable React Native autolinking first.' unless bridge

  if engine_path
    path = Pathname.new(engine_path).expand_path
    raise "CCDAEngine package manifest not found at #{path}" unless path.join('Package.swift').file?

    relative_path = path.relative_path_from(project.path.dirname.expand_path).to_s
    reference = project.root_object.package_references.find do |candidate|
      candidate.isa == 'XCLocalSwiftPackageReference' && candidate.relative_path == relative_path
    end
    unless reference
      reference = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
      reference.relative_path = relative_path
      project.root_object.package_references << reference
    end
  else
    version = engine_version || JSON.parse(File.read(File.join(__dir__, '..', 'package.json'))).fetch('version')
    unless version.is_a?(String) && version.match?(/\A\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?\z/)
      raise 'CCDAEngine version must be an exact semantic version without a v prefix.'
    end
    url = 'https://github.com/ccda-tools/ccda-swift.git'
    reference = project.root_object.package_references.find do |candidate|
      candidate.isa == 'XCRemoteSwiftPackageReference' && candidate.repositoryURL == url
    end
    unless reference
      reference = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
      reference.repositoryURL = url
      project.root_object.package_references << reference
    end
    reference.requirement = { 'kind' => 'exactVersion', 'version' => version }
  end

  product = bridge.package_product_dependencies.find { |dependency| dependency.product_name == 'CCDAEngine' }
  unless product
    product = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
    product.product_name = 'CCDAEngine'
    bridge.package_product_dependencies << product
  end
  previous_reference = product.package
  product.package = reference

  # Migrate projects previously wired to a local engine without leaving stale
  # package references. Preserve references still used by another target.
  if previous_reference && previous_reference != reference
    still_used = project.objects.grep(Xcodeproj::Project::Object::XCSwiftPackageProductDependency).any? do |dependency|
      dependency.package == previous_reference
    end
    previous_reference.remove_from_project unless still_used
  end

  unless bridge.frameworks_build_phase.files.any? { |file| file.product_ref == product }
    build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
    build_file.product_ref = product
    bridge.frameworks_build_phase.files << build_file
  end

  # SwiftPM emits its module beside CocoaPods' per-target product directories.
  bridge.build_configurations.each do |configuration|
    current = configuration.build_settings['SWIFT_INCLUDE_PATHS'] || '$(inherited)'
    paths = current.is_a?(Array) ? current : Shellwords.split(current)
    unless paths.include?('$(PODS_CONFIGURATION_BUILD_DIR)')
      configuration.build_settings['SWIFT_INCLUDE_PATHS'] = (Array(current) + ['$(PODS_CONFIGURATION_BUILD_DIR)']).uniq
    end
  end
end
