require 'json'
package = JSON.parse(File.read(File.join(__dir__, 'package.json')))
Pod::Spec.new do |s|
  s.name = 'SkyvistAdaptiveStatusBar'
  s.version = package['version']
  s.summary = package['description']
  s.homepage = package['homepage']
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = package['author']
  s.source = { :git => package['repository']['url'].delete_prefix('git+'), :tag => "v#{s.version}" }
  s.platforms = { :ios => min_ios_version_supported }
  s.source_files = 'ios/**/*.{h,m,mm,swift}'
  s.exclude_files = 'ios/Tests/**/*', 'ios/SPM/**/*'
  s.private_header_files = 'ios/SkyvistAdaptiveStatusBar.h'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  install_modules_dependencies(s)
end
