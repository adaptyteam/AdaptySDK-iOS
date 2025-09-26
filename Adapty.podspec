Pod::Spec.new do |s|
  s.name             = 'Adapty'
  s.version          = '3.12.0'
  s.summary          = 'Adapty SDK for iOS.'

  s.description      = <<-DESC
Win back churned subscribers in your iOS app.
Adapty helps you track business metrics, and lets you run ad campaigns targeted at churned users faster
                       DESC

  s.homepage         = 'https://adapty.io/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adapty' => 'contact@adapty.io' }
  s.source           = { :git => 'https://github.com/adaptyteam/AdaptySDK-iOS.git', :tag => s.version.to_s }
  s.documentation_url = "https://docs.adapty.io"

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '11.0'

  s.swift_version = '6.0'

  s.default_subspec = 'Core'

  s.subspec 'Logger' do |ss|
    ss.source_files = 'Sources.Logger/**/*.swift'
    
    ss.pod_target_xcconfig = {
        'DEFINES_MODULE' => 'YES',
        'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
    }
  end
  
  s.subspec 'UIBuilder' do |ss|
    ss.source_files = 'Sources.UIBuilder/**/*.swift'
    
    ss.frameworks = 'SwiftUI'
    ss.ios.framework = 'UIKit'

    ss.dependency 'Adapty/Logger'
    
    ss.pod_target_xcconfig = {
        'DEFINES_MODULE' => 'YES',
        'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
    }
  end
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/**/*.swift'
    ss.resource_bundles = {"Adapty" => ["Sources/PrivacyInfo.xcprivacy"]}

    ss.frameworks = 'StoreKit'
    ss.ios.framework = 'UIKit', 'AdSupport'
    ss.ios.weak_frameworks = 'AdServices'
    ss.osx.frameworks = 'AppKit'
    ss.osx.weak_frameworks = 'AdSupport', 'AdServices'
  
    ss.dependency 'Adapty/Logger'
    ss.dependency 'Adapty/UIBuilder'
    
    ss.pod_target_xcconfig = {
        'DEFINES_MODULE' => 'YES',
        'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
    }
  end
  
  s.subspec 'UI' do |ss|
    ss.source_files = 'Sources.AdaptyUI/**/*.swift'
    ss.resource_bundles = {"AdaptyUI" => ["Sources.AdaptyUI/PrivacyInfo.xcprivacy"]}

    ss.frameworks = 'SwiftUI'
    ss.ios.framework = 'UIKit'
  
    ss.dependency 'Adapty/Logger'
    ss.dependency 'Adapty/UIBuilder'
    ss.dependency 'Adapty/Core'
    
    ss.pod_target_xcconfig = {
        'DEFINES_MODULE' => 'YES',
        'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
    }
  end
  
  s.subspec 'Plugin' do |ss|
    ss.source_files = 'Sources.AdaptyPlugin/**/*.swift'
    
    ss.dependency 'Adapty/Logger'
    ss.dependency 'Adapty/Core'
    ss.dependency 'Adapty/UI'
    
    ss.pod_target_xcconfig = {
        'DEFINES_MODULE' => 'YES',
        'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
    }
  end
  
  s.subspec 'DeveloperTools' do |ss|
    ss.source_files = 'Sources.DeveloperTools/**/*.swift'
    
    ss.dependency 'Adapty/Logger'
    ss.dependency 'Adapty/Core'
    ss.dependency 'Adapty/UI'
    
    ss.pod_target_xcconfig = {
        'DEFINES_MODULE' => 'YES',
        'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
    }
  end

end
