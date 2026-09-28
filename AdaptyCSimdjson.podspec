Pod::Spec.new do |s|
  s.name             = 'AdaptyCSimdjson'
  s.module_name      = 'CSimdjson'
  s.version          = '4.2.0'
  s.summary          = 'simdjson C bridge used by the Adapty SDK.'

  s.description      = <<-DESC
  C interface over simdjson used internally by AdaptyCodable.
                       DESC

  s.homepage          = 'https://adapty.io/'
  s.license           = { :type => 'MIT', :file => 'LICENSE' }
  s.author            = { 'Adapty' => 'contact@adapty.io' }
  s.source            = { :git => 'https://github.com/adaptyteam/AdaptySDK-iOS.git', :tag => s.version.to_s }
  s.documentation_url = "https://docs.adapty.io"

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'

  s.source_files        = 'Sources.Codable/CSimdjson/**/*.{h,cpp}'
  s.public_header_files = 'Sources.Codable/CSimdjson/include/SimdjsonBridge.h'
  s.libraries           = 'c++'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++20',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SIMDJSON_EXCEPTIONS=0',
    'GCC_PREPROCESSOR_DEFINITIONS[config=Release]' => '$(inherited) SIMDJSON_EXCEPTIONS=0 NDEBUG=1'
  }
end
