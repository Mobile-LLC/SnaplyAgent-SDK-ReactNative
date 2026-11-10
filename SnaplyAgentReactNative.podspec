require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "SnaplyAgentReactNative"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = { :type => "Proprietary", :file => "LICENSE" }
  s.authors      = "iFixgroup"
  s.platforms    = { :ios => "15.1" }
  s.source       = { :git => "https://github.com/Mobile-LLC/SnaplyAgent-SDK-ReactNative.git", :tag => "v#{s.version}" }

  s.source_files = "ios/Sources/**/*.{h,m,mm,swift}"
  s.private_header_files = "ios/Sources/**/*.h"
  s.swift_version = "5.9"
  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES" }

  # The Snaply Agent iOS SDK, the same binary its own repository publishes. It is carried here rather than
  # declared as a Swift package: React Native's spm_dependency links a binary framework without copying it
  # into the app, and the app then stops at launch ("Library not loaded", measured 2026-11-10).
  # scripts/vendor-ios-sdk.sh brings it in and checks it against the published checksums.
  s.vendored_frameworks = "ios/Frameworks/SnaplyAgent.xcframework"

  install_modules_dependencies(s)
end
