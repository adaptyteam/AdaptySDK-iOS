require 'minitest/autorun'
require 'json'
require 'open3'
require 'tmpdir'
require 'fileutils'
require_relative '../verify_artifact'

class VerifyArtifactTest < Minitest::Test
  SHA = '28038b667097a259d2762ae1e37a8de0593ada3a'
  OTHER_SHA = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
  SCRIPT = File.expand_path('../verify_artifact.rb', __dir__)

  def setup
    @tmp = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def stage(version: '4.3.0', mode: 'tag', ref: '4.3.0', sha: SHA, pods: AdaptyPods::ORDER, manifest: {})
    dir = File.join(@tmp, 'staged')
    FileUtils.mkdir_p(dir)
    source = AdaptyPods.expected_source(mode, ref, sha)
    pods.each do |pod|
      path = File.join(dir, AdaptyPods.spec_path(pod, version))
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.pretty_generate('name' => pod, 'version' => version, 'source' => source))
    end
    data = { 'version' => version, 'mode' => mode, 'ref' => ref, 'sha' => sha, 'pods' => pods }.merge(manifest)
    File.write(File.join(dir, 'manifest.json'), JSON.generate(data))
    dir
  end

  def spec_file(dir, pod, version = '4.3.0')
    File.join(dir, AdaptyPods.spec_path(pod, version))
  end

  def assert_rejected(message, dir, expected = {})
    error = assert_raises(VerifyError) { VerifyArtifact.call(dir, expected) }
    assert_includes error.message, message
  end

  def test_accepts_tag_artifact
    assert_equal '4.3.0', VerifyArtifact.call(stage)['version']
  end

  def test_accepts_commit_artifact
    dir = stage(version: '4.3.0-SNAPSHOT.1', mode: 'commit', ref: 'origin/dev')
    assert_equal 'commit', VerifyArtifact.call(dir)['mode']
  end

  def test_prerelease_version
    dir = stage(version: '4.3.0-SNAPSHOT.1', mode: 'commit', ref: SHA, pods: %w[AdaptyLogger])
    assert_equal %w[AdaptyLogger], VerifyArtifact.call(dir)['pods']
  end

  def test_accepts_subset_of_pods
    assert_equal %w[Adapty AdaptyUI], VerifyArtifact.call(stage(pods: %w[Adapty AdaptyUI]))['pods']
  end

  def test_rejects_missing_manifest
    dir = stage
    File.delete(File.join(dir, 'manifest.json'))
    assert_rejected 'missing manifest.json', dir
  end

  def test_rejects_extra_file
    dir = stage
    File.write(File.join(dir, 'Specs', 'evil.sh'), 'echo')
    assert_rejected 'unexpected files: Specs/evil.sh', dir
  end

  def test_rejects_spec_not_in_manifest
    dir = stage(manifest: { 'pods' => %w[Adapty] })
    assert_rejected 'unexpected files', dir
  end

  def test_rejects_missing_spec
    dir = stage
    File.delete(spec_file(dir, 'AdaptyUI'))
    assert_rejected 'missing files', dir
  end

  def test_rejects_symlink
    dir = stage
    File.delete(spec_file(dir, 'AdaptyUI'))
    File.symlink(spec_file(dir, 'Adapty'), spec_file(dir, 'AdaptyUI'))
    assert_rejected 'not a regular file', dir
  end

  def test_rejects_unknown_pod
    assert_rejected 'unknown pods: Evil', stage(manifest: { 'pods' => %w[Evil] })
  end

  def test_rejects_traversal_version
    assert_rejected 'invalid version', stage(manifest: { 'version' => '../4.3.0' })
  end

  def test_rejects_bad_sha
    assert_rejected 'sha must be', stage(manifest: { 'sha' => 'main' })
  end

  def test_rejects_tag_not_matching_version
    assert_rejected 'does not match version', stage(manifest: { 'ref' => '4.3.1' })
  end

  def test_rejects_wrong_name
    dir = stage
    File.write(spec_file(dir, 'Adapty'), JSON.generate('name' => 'Evil', 'version' => '4.3.0',
                                                        'source' => AdaptyPods.expected_source('tag', '4.3.0', SHA)))
    assert_rejected 'Adapty: name', dir
  end

  def test_rejects_wrong_version_in_spec
    dir = stage
    File.write(spec_file(dir, 'Adapty'), JSON.generate('name' => 'Adapty', 'version' => '4.2.0',
                                                        'source' => AdaptyPods.expected_source('tag', '4.3.0', SHA)))
    assert_rejected 'Adapty: version', dir
  end

  def test_rejects_wrong_source
    dir = stage
    File.write(spec_file(dir, 'Adapty'), JSON.generate('name' => 'Adapty', 'version' => '4.3.0',
                                                        'source' => { 'git' => 'https://example.com/fork.git', 'tag' => '4.3.0' }))
    assert_rejected 'Adapty: source', dir
  end

  def test_rejects_commit_source_in_tag_mode
    dir = stage
    File.write(spec_file(dir, 'Adapty'), JSON.generate('name' => 'Adapty', 'version' => '4.3.0',
                                                        'source' => AdaptyPods.expected_source('commit', '4.3.0', SHA)))
    assert_rejected 'Adapty: source', dir
  end

  def test_expected_run_matches
    assert VerifyArtifact.call(stage, sha: SHA, mode: 'tag', ref: '4.3.0')
  end

  def test_rejects_other_sha_than_run
    assert_rejected 'is not the run', stage, sha: OTHER_SHA, mode: 'tag', ref: '4.3.0'
  end

  def test_rejects_other_mode_than_run
    assert_rejected 'is not the run', stage, sha: SHA, mode: 'commit', ref: '4.3.0'
  end

  def test_rejects_other_tag_than_run
    assert_rejected 'is not the run', stage, sha: SHA, mode: 'tag', ref: '4.2.0'
  end

  def test_rejects_partial_expectation
    assert_rejected 'not set', stage, sha: SHA, mode: nil, ref: nil
  end

  def test_cli_prints_manifest_and_reads_env
    dir = stage
    out, err, status = Open3.capture3({ 'EXPECTED_SHA' => SHA, 'EXPECTED_MODE' => 'tag', 'EXPECTED_REF' => '4.3.0' },
                                      'ruby', SCRIPT, dir)
    assert status.success?, err
    assert_equal '4.3.0', JSON.parse(out)['version']
  end

  def test_cli_fails_with_reason
    _out, err, status = Open3.capture3({ 'EXPECTED_SHA' => OTHER_SHA, 'EXPECTED_MODE' => 'tag', 'EXPECTED_REF' => '4.3.0' },
                                       'ruby', SCRIPT, stage)
    refute status.success?
    assert_includes err, 'verify: '
  end
end
