Pod::Spec.new do |s|
  s.name             = 'AdaptyPlugin'
  s.version          = '3.15.1'
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

  s.ios.deployment_target = '13.0'

  s.swift_version = '6.0'

  s.source_files = 'Sources.AdaptyPlugin/**/*.{h,m,mm,swift}'

  s.dependency 'AdaptyLogger', s.version.to_s
  s.dependency 'AdaptyUIBuilder', s.version.to_s
  s.dependency 'Adapty', s.version.to_s
  s.dependency 'AdaptyUI', s.version.to_s

  s.frameworks = 'StoreKit'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
  }
end
