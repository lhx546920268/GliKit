#
#  Be sure to run `pod spec lint GliKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "GliKit"
  spec.version      = "1.2.0"
  spec.summary      = "A short description of GliKit."

  spec.description  = <<-DESC
                        这是一个描述
                   DESC

  spec.homepage     = "http://EXAMPLE/GliKit"
  spec.license      = "MIT"

  spec.author             = "luohaixiong"

  spec.platform     = :ios, "11.0"
  #pod中的macro
  #spec.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'MAS_SHORTHAND_GLOBALS=1'}
  #项目中的macro
  #spec.user_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'MAS_SHORTHAND_GLOBALS=1'}
  spec.source = { :git => "https://www.github.com/lhx546920268/GliKit"}
  spec.source_files  = "GliKit/**/*.{h,m}"
  spec.dependency 'SDWebImage', '~> 5.15.8'
  spec.dependency 'Masonry', '~> 1.1.0'
  spec.dependency 'AFNetworking/NSURLSession', '~> 4.0.1'
  spec.dependency 'AFNetworking/Reachability', '~> 4.0.1'
  spec.dependency 'AFNetworking/Security', '~> 4.0.1'
  spec.dependency 'AFNetworking/Serialization', '~> 4.0.1'
  spec.dependency 'FMDB', '~> 2.7.5'
end
