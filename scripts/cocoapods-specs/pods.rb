# The Adapty pods published to AdaptySDK-CocoaPods-Specs, in dependency order.
module AdaptyPods
  ORDER = %w[AdaptyLogger AdaptyCSimdjson AdaptyCodable AdaptyUIBuilder Adapty AdaptyUI AdaptyPlugin].freeze
  IOS_GIT = 'https://github.com/adaptyteam/AdaptySDK-iOS.git'.freeze

  def self.spec_path(pod, version)
    File.join('Specs', pod, version, "#{pod}.podspec.json")
  end

  def self.expected_source(mode, ref, sha)
    case mode
    when 'tag' then { 'git' => IOS_GIT, 'tag' => ref }
    when 'commit' then { 'git' => IOS_GIT, 'commit' => sha }
    else raise ArgumentError, "unknown mode: #{mode}"
    end
  end
end

puts AdaptyPods::ORDER if $PROGRAM_NAME == __FILE__
