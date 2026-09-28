Pod::Spec.new do |s|
  s.name             = 'AdaptyCodable'
  s.version          = '4.2.0'
  s.summary          = 'Codable helpers used by the Adapty SDK.'

  s.description      = <<-DESC
  Codable utilities and simdjson-backed JSON extraction used by Adapty and AdaptyUIBuilder.
                       DESC

  s.homepage          = 'https://adapty.io/'
  s.license           = { :type => 'MIT', :file => 'LICENSE' }
  s.author            = { 'Adapty' => 'contact@adapty.io' }
  s.source            = { :git => 'https://github.com/adaptyteam/AdaptySDK-iOS.git', :tag => s.version.to_s }
  s.documentation_url = "https://docs.adapty.io"

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'

  s.swift_version = '6.0'

  s.source_files = 'Sources.Codable/*.swift'

  s.dependency 'AdaptyCSimdjson', s.version.to_s

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
  }
end
