#
# Be sure to run `pod lib lint Adapty.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Adapty'
  s.version          = '1.12.7'
  s.summary          = 'Adapty SDK for iOS.'

  s.description      = <<-DESC
Win back churned subscribers in your iOS app.
Adapty helps you track business metrics, and lets you run ad campaigns targeted at churned users faster
                       DESC

  s.homepage         = 'https://adapty.io/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adapty' => 'contact@adapty.io' }
  s.source           = { :git => 'https://github.com/adaptyteam/AdaptySDK-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.14.4'

  s.swift_versions = ['5.0', '5.1']
  
  s.source_files = 'Adapty/Classes/**/*'

  s.frameworks = 'Foundation', 'AdSupport', 'StoreKit'
  s.ios.framework = 'UIKit'
  s.osx.frameworks = 'AppKit'
  s.dependency 'CryptoSwift', '1.3.2'
end
