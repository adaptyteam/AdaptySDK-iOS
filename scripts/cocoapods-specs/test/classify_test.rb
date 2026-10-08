require 'minitest/autorun'
require 'json'
require 'open3'
require 'tmpdir'
require 'fileutils'
require_relative '../classify'

class ClassifyTest < Minitest::Test
  SHA = '28038b667097a259d2762ae1e37a8de0593ada3a'
  SCRIPT = File.expand_path('../classify.rb', __dir__)

  def setup
    @repo = Dir.mktmpdir
    @tag = AdaptyPods.expected_source('tag', '4.3.0', SHA)
  end

  def teardown
    FileUtils.remove_entry(@repo)
  end

  def publish(pod, version, source)
    path = File.join(@repo, AdaptyPods.spec_path(pod, version))
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.generate('name' => pod, 'version' => version, 'source' => source))
  end

  def test_all_new_in_empty_repo
    result = Classify.call(@repo, '4.3.0', @tag)
    assert_equal AdaptyPods::ORDER, result.keys
    assert_equal ['new'], result.values.uniq
  end

  def test_mixed_statuses
    publish('AdaptyLogger', '4.3.0', @tag)
    publish('AdaptyCSimdjson', '4.3.0', AdaptyPods.expected_source('commit', 'dev', SHA))
    result = Classify.call(@repo, '4.3.0', @tag)
    assert_equal 'skip', result['AdaptyLogger']
    assert_equal 'conflict', result['AdaptyCSimdjson']
    assert_equal 'new', result['AdaptyCodable']
  end

  def test_directory_without_spec_is_conflict
    FileUtils.mkdir_p(File.join(@repo, 'Specs', 'Adapty', '4.3.0'))
    assert_equal 'conflict', Classify.call(@repo, '4.3.0', @tag)['Adapty']
  end

  def test_unparsable_spec_is_conflict
    path = File.join(@repo, AdaptyPods.spec_path('Adapty', '4.3.0'))
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, 'not json')
    assert_equal 'conflict', Classify.call(@repo, '4.3.0', @tag)['Adapty']
  end

  def test_non_object_spec_is_conflict
    path = File.join(@repo, AdaptyPods.spec_path('Adapty', '4.3.0'))
    FileUtils.mkdir_p(File.dirname(path))
    ['null', '[]', '1', '"x"'].each do |content|
      File.write(path, content)
      assert_equal 'conflict', Classify.call(@repo, '4.3.0', @tag)['Adapty'], content
    end
  end

  def test_other_versions_do_not_matter
    publish('Adapty', '4.2.2', @tag)
    assert_equal 'new', Classify.call(@repo, '4.3.0', @tag)['Adapty']
  end

  def test_prerelease_version
    source = AdaptyPods.expected_source('commit', 'dev', SHA)
    publish('Adapty', '4.3.0-SNAPSHOT.1', source)
    assert_equal 'skip', Classify.call(@repo, '4.3.0-SNAPSHOT.1', source)['Adapty']
  end

  def test_cli_prints_statuses_in_order
    publish('AdaptyLogger', '4.3.0', @tag)
    out, err, status = Open3.capture3('ruby', SCRIPT, '--repo', @repo, '--version', '4.3.0',
                                      '--source', JSON.generate(@tag), '--pods', 'AdaptyCodable,AdaptyLogger')
    assert status.success?, err
    assert_equal "AdaptyCodable new\nAdaptyLogger skip\n", out
  end

  def test_cli_rejects_unknown_pod
    _out, err, status = Open3.capture3('ruby', SCRIPT, '--repo', @repo, '--version', '4.3.0',
                                       '--source', JSON.generate(@tag), '--pods', 'Evil')
    refute status.success?
    assert_includes err, 'unknown pods: Evil'
  end

  def test_cli_rejects_missing_arguments
    _out, err, status = Open3.capture3('ruby', SCRIPT, '--repo', @repo)
    refute status.success?
    assert_includes err, 'required'
  end

  def test_cli_rejects_invalid_source
    _out, err, status = Open3.capture3('ruby', SCRIPT, '--repo', @repo, '--version', '4.3.0', '--source', '{')
    refute status.success?
    assert_includes err, '--source'
  end
end
