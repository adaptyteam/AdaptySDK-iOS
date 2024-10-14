#
# Be sure to run `pod lib lint Adapty.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AdaptyCrossPlatformCommon'
  s.version          = '3.1.0-SNAPSHOT'
  s.summary          = 'Common files for cross-platform SDKs Adapty'

  s.description      = <<-DESC
Win back churned subscribers in your iOS app.
Adapty helps you track business metrics, and lets you run ad campaigns targeted at churned users faster

  AdaptyCrossPlatformCommon is an extension for AdaptySDK.
                       DESC

  s.homepage         = 'https://adapty.io/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adapty' => 'contact@adapty.io' }
  s.source           = { :git => 'https://github.com/adaptyteam/AdaptySDK-iOS.git', :tag => s.version.to_s }
  s.documentation_url = "https://docs.adapty.io"

  s.ios.deployment_target = '12.2'
  s.osx.deployment_target = '10.14.4'
  s.visionos.deployment_target = '1.0'

  s.swift_version = '5.9'

  s.source_files = 'CrossPlatformCommon/**/*.{h,m,mm,swift}'

  s.dependency 'Adapty', s.version.to_s

  s.frameworks = 'StoreKit'

  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
  }

end
