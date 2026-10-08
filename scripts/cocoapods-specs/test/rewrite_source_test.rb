require 'minitest/autorun'
require 'json'
require 'open3'
require_relative '../rewrite_source'

class RewriteSourceTest < Minitest::Test
  SHA = '28038b667097a259d2762ae1e37a8de0593ada3a'
  GIT = 'https://github.com/adaptyteam/AdaptySDK-iOS.git'
  SPEC = {
    'name' => 'AdaptyLogger',
    'version' => '4.2.0-SNAPSHOT',
    'source' => { 'git' => GIT, 'tag' => '4.2.0-SNAPSHOT' },
    'source_files' => 'Sources.Logger/**/*.swift',
  }.freeze
  SCRIPT = File.expand_path('../rewrite_source.rb', __dir__)

  def test_pins_source_to_commit_and_drops_tag
    assert_equal({ 'git' => GIT, 'commit' => SHA }, rewrite_source(SPEC, SHA)['source'])
  end

  def test_keeps_other_fields
    without_source = ->(spec) { spec.reject { |key, _| key == 'source' } }
    assert_equal without_source.(SPEC), without_source.(rewrite_source(SPEC, SHA))
  end

  def test_without_commit_returns_spec_unchanged
    assert_equal SPEC, rewrite_source(SPEC, nil)
  end

  def test_rejects_source_without_git
    http_spec = SPEC.merge('source' => { 'http' => 'https://example.com/sdk.zip' })
    assert_raises(ArgumentError) { rewrite_source(http_spec, SHA) }
  end

  def test_rejects_string_source
    assert_raises(ArgumentError) { rewrite_source(SPEC.merge('source' => GIT), SHA) }
  end

  def test_cli_pins_commit
    out, status = Open3.capture2('ruby', SCRIPT, '--commit', SHA, stdin_data: JSON.generate(SPEC))
    assert status.success?
    assert_equal SHA, JSON.parse(out).dig('source', 'commit')
  end

  def test_cli_fails_on_invalid_json
    _out, err, status = Open3.capture3('ruby', SCRIPT, '--commit', SHA, stdin_data: 'not json')
    refute status.success?
    refute_empty err
  end

  def test_cli_rejects_flag_as_commit
    _out, err, status = Open3.capture3('ruby', SCRIPT, '--commit', '--foo', stdin_data: JSON.generate(SPEC))
    refute status.success?
    assert_includes err, '--commit needs a SHA'
  end

  def test_cli_rejects_non_object_json
    _out, err, status = Open3.capture3('ruby', SCRIPT, '--commit', SHA, stdin_data: '[]')
    refute status.success?
    assert_includes err, 'must be an object'
  end
end
