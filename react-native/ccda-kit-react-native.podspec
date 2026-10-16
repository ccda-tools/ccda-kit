require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'ccda-kit-react-native'
  s.version = package['version']
  s.summary = package['description']
  s.license = { :type => 'MIT' }
  s.author = 'ccda-kit contributors'
  s.homepage = 'https://github.com/ccda-tools/ccda-kit'
  s.source = { :git => 'https://github.com/ccda-tools/ccda-kit.git', :tag => "v#{s.version}" }
  s.platforms = { :ios => '16.0' }
  s.swift_version = '5.9'
  s.source_files = 'ios/*.{h,m,mm,swift}'
  s.dependency 'React-Core'

  s.test_spec 'Native' do |tests|
    tests.source_files = 'ios/Tests/*.m'
    tests.frameworks = 'XCTest', 'UIKit', 'WebKit'
    tests.requires_app_host = true
  end
end
