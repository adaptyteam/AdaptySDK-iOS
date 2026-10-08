require 'minitest/autorun'
require 'open3'
require_relative '../pods'

class PodsTest < Minitest::Test
  SHA = '28038b667097a259d2762ae1e37a8de0593ada3a'

  def test_order_is_dependency_order
    assert_equal %w[AdaptyLogger AdaptyCSimdjson AdaptyCodable AdaptyUIBuilder Adapty AdaptyUI AdaptyPlugin],
                 AdaptyPods::ORDER
  end

  def test_spec_path
    assert_equal 'Specs/Adapty/4.3.0-SNAPSHOT.1/Adapty.podspec.json', AdaptyPods.spec_path('Adapty', '4.3.0-SNAPSHOT.1')
  end

  def test_expected_source_for_tag
    assert_equal({ 'git' => AdaptyPods::IOS_GIT, 'tag' => '4.3.0' }, AdaptyPods.expected_source('tag', '4.3.0', SHA))
  end

  def test_expected_source_for_commit
    assert_equal({ 'git' => AdaptyPods::IOS_GIT, 'commit' => SHA },
                 AdaptyPods.expected_source('commit', 'origin/dev', SHA))
  end

  def test_expected_source_rejects_unknown_mode
    assert_raises(ArgumentError) { AdaptyPods.expected_source('branch', 'dev', SHA) }
  end

  def test_cli_prints_order
    out, status = Open3.capture2('ruby', File.expand_path('../pods.rb', __dir__))
    assert status.success?
    assert_equal AdaptyPods::ORDER, out.split("\n")
  end
end
