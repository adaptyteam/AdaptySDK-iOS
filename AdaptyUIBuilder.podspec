Pod::Spec.new do |s|
  s.name         = 'AdaptyUIBuilder'
  s.version          = '4.0.0-SNAPSHOT'
  s.summary      = 'Adapty UI Builder for iOS.'
  
  s.description    = <<-DESC
  Win back churned subscribers in your iOS app.
  Adapty helps you track business metrics, and lets you run ad campaigns targeted at churned users faster
             DESC
  
  s.homepage     = 'https://adapty.io/'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Adapty' => 'contact@adapty.io' }
  s.source       = { :git => 'https://github.com/adaptyteam/AdaptySDK-iOS.git', :tag => s.version.to_s }
  s.documentation_url = "https://docs.adapty.io"
  
  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  
  s.swift_version = '6.0'
  
  s.source_files = 'Sources.UIBuilder/**/*.swift'
  
  s.frameworks = 'SwiftUI'
  s.ios.framework = 'UIKit'
  
  s.dependency 'AdaptyLogger', s.version.to_s
    
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
  }
end
  
