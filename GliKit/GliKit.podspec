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

  spec.homepage     = "http://EXAMPLE/iOSLib"
  spec.license      = "MIT"

  spec.author             = "luohaixiong"

  spec.platform     = :ios, "9.0"

  spec.source = { :git => "https://github.com/lhx546920268/GliKit.git", :tag => "v#{spec.version}" }
  spec.source_files  = "GliKit/**/*.{h,m}"
  spec.dependency 'SDWebImage'
  spec.dependency 'Masonry'
  spec.dependency 'AFNetworking'
  spec.dependency 'FMDB'
end
