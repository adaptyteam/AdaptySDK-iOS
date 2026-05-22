Pod::Spec.new do |s|
  s.name         = 'AdaptyCodable'
  s.version      = '4.0.0-SNAPSHOT'
  s.summary      = 'Adapty Codable helpers and simdjson-backed decoding.'

  s.description  = <<-DESC
  Codable utilities used by the Adapty iOS SDK. Wraps a C bridge over simdjson
  (the CBridge subspec) and provides Swift Decoder/Encoder extensions consumed
  by Adapty and AdaptyUIBuilder.
  DESC

  s.homepage          = 'https://adapty.io/'
  s.license           = { :type => 'MIT', :file => 'LICENSE' }
  s.author            = { 'Adapty' => 'contact@adapty.io' }
  s.source            = { :git => 'https://github.com/adaptyteam/AdaptySDK-iOS.git', :tag => s.version.to_s }
  s.documentation_url = "https://docs.adapty.io"

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'

  s.swift_version = '6.0'

  s.default_subspecs = ['Swift']

  s.subspec 'CBridge' do |ss|
    ss.source_files        = 'Sources.Codable/CSimdjson/**/*.{h,hpp,cpp}'
    ss.public_header_files = 'Sources.Codable/CSimdjson/include/SimdjsonBridge.h'
    ss.private_header_files = 'Sources.Codable/CSimdjson/simdjson.h'
    ss.exclude_files       = 'Sources.Codable/CSimdjson/include/module.modulemap'

    ss.pod_target_xcconfig = {
      'DEFINES_MODULE'               => 'YES',
      'CLANG_CXX_LANGUAGE_STANDARD'  => 'c++20',
      'CLANG_CXX_LIBRARY'            => 'libc++',
      'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SIMDJSON_EXCEPTIONS=0',
      'HEADER_SEARCH_PATHS'          => '$(inherited) "$(PODS_TARGET_SRCROOT)/Sources.Codable/CSimdjson"',
    }
  end

  s.subspec 'Swift' do |ss|
    ss.source_files = 'Sources.Codable/*.swift'
    ss.dependency 'AdaptyCodable/CBridge'

    ss.pod_target_xcconfig = {
      'DEFINES_MODULE'    => 'YES',
      'OTHER_SWIFT_FLAGS' => '-package-name io.adapty.sdk'
    }
  end
end
