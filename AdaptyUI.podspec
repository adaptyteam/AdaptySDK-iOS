Pod::Spec.new do |s|
  s.name             = 'AdaptyUI'
  s.version          = '3.15.0'
  s.summary          = 'Adapty SDK for iOS.'

  s.description      = <<-DESC
Win back churned subscribers in your iOS app.
Adapty helps you track business metrics, and lets you run ad campaigns targeted at churned users faster

AdaptyUI is an extension for AdaptySDK.
                       DESC

  s.homepage         = 'https://adapty.io/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adapty' => 'contact@adapty.io' }
  s.source           = { :git => 'https://github.com/adaptyteam/AdaptySDK-iOS.git', :tag => s.version.to_s }
  s.documentation_url = "https://docs.adapty.io"

  s.ios.deployment_target = '13.0'
  s.swift_version = '6.0'
  
  s.source_files = 'Sources.AdaptyUI/**/*.swift'
  s.resource_bundles = {"AdaptyUI" => ["Sources.AdaptyUI/PrivacyInfo.xcprivacy"]}

  s.dependency 'AdaptyLogger', s.version.to_s
  s.dependency 'AdaptyUIBuilder', s.version.to_s
  s.dependency 'Adapty', s.version.to_s

  s.frameworks = 'SwiftUI'
  s.ios.framework = 'UIKit'

  s.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES',
      'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
  }
end
