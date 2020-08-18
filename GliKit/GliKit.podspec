#
#  Be sure to run `pod spec lint GliKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "GliKit"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of GliKit."

  spec.description  = <<-DESC
                        这是一个描述
                   DESC

  spec.homepage     = "http://EXAMPLE/GliKit"
  spec.license      = "MIT"

  spec.author             = "luohaixiong"

  spec.platform     = :ios, "9.0"

  spec.source = { :git => "https://www.github.com/lhx546920268/GliKit"}
  spec.source_files  = "GliKit/**/*.{h,m}"
  spec.dependency 'SDWebImage', '~> 5.7.2'
  spec.dependency 'Masonry', '~> 1.1.0'
  spec.dependency 'AFNetworking', '~> 4.0.0'
  spec.dependency 'FMDB', '~> 2.7.5'
end
