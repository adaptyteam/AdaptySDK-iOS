#
# Be sure to run `pod lib lint Adapty.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Adapty'
  s.version          = '2.10.2'
  s.summary          = 'Adapty SDK for iOS.'

  s.description      = <<-DESC
Win back churned subscribers in your iOS app.
Adapty helps you track business metrics, and lets you run ad campaigns targeted at churned users faster
                       DESC

  s.homepage         = 'https://adapty.io/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adapty' => 'contact@adapty.io' }
  s.source           = { :git => 'https://github.com/adaptyteam/AdaptySDK-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.2'
  s.osx.deployment_target = '10.14.4'
  s.visionos.deployment_target = '1.0'

  s.swift_version = '5.9'
  
  s.source_files = 'Sources/**/*.swift'
  s.resource_bundles = {"Adapty" => ["Sources/Resources/PrivacyInfo.xcprivacy"]}

  s.frameworks = 'Foundation', 'StoreKit'
  s.ios.framework = 'UIKit', 'AdSupport'
  s.ios.weak_frameworks = 'AdServices'
  s.osx.frameworks = 'AppKit'
  s.osx.weak_frameworks = 'AdSupport', 'AdServices'
end
