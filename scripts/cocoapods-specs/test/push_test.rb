require 'minitest/autorun'
require 'json'
require 'open3'
require 'tmpdir'
require 'fileutils'
require_relative '../pods'

class PushTest < Minitest::Test
  SCRIPT = File.expand_path('../publish.sh', __dir__)
  # nil unsets the variable for the child process.
  ENV_VARS = {
    'GIT_AUTHOR_NAME' => 'Test', 'GIT_AUTHOR_EMAIL' => 'test@example.com',
    'GIT_COMMITTER_NAME' => 'Test', 'GIT_COMMITTER_EMAIL' => 'test@example.com',
    'EXPECTED_SHA' => nil, 'EXPECTED_MODE' => nil, 'EXPECTED_REF' => nil, 'GITHUB_RUN_ID' => nil
  }.freeze

  def setup
    @tmp = Dir.mktmpdir
    @specs = File.join(@tmp, 'specs.git')
    git('init', '--quiet', '--bare', '--initial-branch=main', @specs)
    seed = File.join(@tmp, 'seed')
    git('clone', '--quiet', @specs, seed)
    FileUtils.mkdir_p(File.join(seed, 'Specs'))
    File.write(File.join(seed, 'Specs', '.gitkeep'), '')
    git('-C', seed, 'add', '.')
    git('-C', seed, 'commit', '--quiet', '-m', 'init')
    git('-C', seed, 'push', '--quiet', 'origin', 'HEAD:refs/heads/main')

    ios = File.join(@tmp, 'ios')
    git('init', '--quiet', ios)
    git('-C', ios, 'commit', '--quiet', '--allow-empty', '-m', 'release')
    @sha = git('-C', ios, 'rev-parse', 'HEAD').strip
    git('-C', ios, 'tag', '-a', '9.9.9', '-m', '9.9.9')
    git('-C', ios, 'tag', '8.8.8')
    git('-C', ios, 'commit', '--quiet', '--allow-empty', '-m', 'later')
    @other_sha = git('-C', ios, 'rev-parse', 'HEAD').strip
    @ios_url = "file://#{ios}"
    @count = 0
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def git(*args)
    out, err, status = Open3.capture3(ENV_VARS, 'git', *args)
    raise "git #{args.join(' ')}: #{err}" unless status.success?

    out
  end

  def stage(version: '9.9.9', mode: 'tag', ref: '9.9.9', sha: @sha, pods: AdaptyPods::ORDER)
    @count += 1
    dir = File.join(@tmp, "staged-#{@count}")
    FileUtils.mkdir_p(dir)
    source = AdaptyPods.expected_source(mode, ref, sha)
    pods.each do |pod|
      path = File.join(dir, AdaptyPods.spec_path(pod, version))
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.pretty_generate('name' => pod, 'version' => version, 'source' => source))
    end
    File.write(File.join(dir, 'manifest.json'),
               JSON.generate('version' => version, 'mode' => mode, 'ref' => ref, 'sha' => sha, 'pods' => pods))
    dir
  end

  def run_script(*args, env: {})
    Open3.capture3(ENV_VARS.merge(env), '/bin/bash', SCRIPT, *args)
  end

  def push(dir, env: {})
    run_script('push', '--from', dir, '--specs-url', "file://#{@specs}", '--ios-url', @ios_url, env: env)
  end

  def log
    git("--git-dir=#{@specs}", 'log', '--format=%s', 'main').lines.map(&:strip)
  end

  def published?(pod, version)
    !git("--git-dir=#{@specs}", 'ls-tree', '--name-only', 'main', '--', AdaptyPods.spec_path(pod, version)).strip.empty?
  end

  def test_annotated_tag
    _out, err, status = push(stage)
    assert status.success?, err
    assert_equal ['[Add] Adapty pods (9.9.9)', 'init'], log
    assert(AdaptyPods::ORDER.all? { |pod| published?(pod, '9.9.9') })
  end

  def test_lightweight_tag
    _out, err, status = push(stage(version: '8.8.8', ref: '8.8.8'))
    assert status.success?, err
    assert_equal ['[Add] Adapty pods (8.8.8)', 'init'], log
  end

  def test_commit_mode
    _out, err, status = push(stage(version: '9.9.10-SNAPSHOT.1', mode: 'commit', ref: 'origin/dev', sha: @other_sha))
    assert status.success?, err
    assert published?('AdaptyPlugin', '9.9.10-SNAPSHOT.1')
  end

  def test_second_run_is_a_noop
    push(stage)
    out, err, status = push(stage)
    assert status.success?, err
    assert_includes out, 'Nothing to publish'
    assert_equal 2, log.size
  end

  def test_adds_only_missing_pods
    push(stage(pods: AdaptyPods::ORDER.first(3)))
    out, err, status = push(stage)
    assert status.success?, err
    assert_includes out, 'skip: AdaptyLogger 9.9.9'
    assert_equal 3, log.size
    assert published?('AdaptyPlugin', '9.9.9')
  end

  def test_refuses_foreign_source_without_pushing
    push(stage(mode: 'commit', ref: 'origin/dev'))
    _out, err, status = push(stage)
    refute status.success?
    assert_includes err, 'another source'
    assert_equal 2, log.size
  end

  def test_refuses_tag_on_other_commit
    _out, err, status = push(stage(sha: @other_sha))
    refute status.success?
    assert_includes err, 'does not point to'
    assert_equal 1, log.size
  end

  def test_refuses_missing_tag
    _out, err, status = push(stage(version: '7.7.7', ref: '7.7.7'))
    refute status.success?
    assert_includes err, 'does not point to'
  end

  def test_rejects_bad_artifact_before_network
    dir = stage
    File.write(File.join(dir, 'extra.txt'), 'x')
    _out, err, status = run_script('push', '--from', dir, '--specs-url', 'file:///nonexistent.git', '--ios-url', @ios_url)
    refute status.success?
    assert_includes err, 'unexpected files'
  end

  def test_rejects_artifact_of_another_run
    _out, err, status = push(stage, env: { 'EXPECTED_SHA' => @other_sha, 'EXPECTED_MODE' => 'tag', 'EXPECTED_REF' => '9.9.9' })
    refute status.success?
    assert_includes err, 'is not the run'
    assert_equal 1, log.size
  end

  def test_retries_rejected_push
    marker = File.join(@tmp, 'rejected-once')
    hook = File.join(@specs, 'hooks', 'pre-receive')
    File.write(hook, "#!/bin/sh\nif [ ! -f '#{marker}' ]; then touch '#{marker}'; echo 'simulated rejection' >&2; exit 1; fi\n")
    File.chmod(0o755, hook)
    _out, err, status = push(stage)
    assert status.success?, err
    assert_includes err, 'retrying'
    assert_equal ['[Add] Adapty pods (9.9.9)', 'init'], log
  end

  # A commit on refs/competing/main that adds the given specs on top of the current main.
  def competing_commit(specs)
    clone = File.join(@tmp, 'competitor')
    git('clone', '--quiet', '--branch', 'main', @specs, clone)
    specs.each do |pod, version, source|
      path = File.join(clone, AdaptyPods.spec_path(pod, version))
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.pretty_generate('name' => pod, 'version' => version, 'source' => source))
    end
    git('-C', clone, 'add', 'Specs')
    git('-C', clone, 'commit', '--quiet', '-m', 'competing')
    git('-C', clone, 'push', '--quiet', 'origin', 'HEAD:refs/competing/main')
    git('-C', clone, 'rev-parse', 'HEAD').strip
  end

  # On the first push only, another publisher's commit lands on main, then ours is rejected.
  # Ref updates are forbidden inside receive-pack's quarantine unless GIT_QUARANTINE_PATH is unset.
  def race_on_first_push(competing_sha)
    calls = File.join(@tmp, 'pre-receive-calls')
    hook = File.join(@specs, 'hooks', 'pre-receive')
    File.write(hook, <<~SH)
      #!/bin/sh
      echo call >> '#{calls}'
      if [ "$(wc -l < '#{calls}')" -eq 1 ]; then
        (unset GIT_QUARANTINE_PATH; git update-ref refs/heads/main #{competing_sha}) || exit 2
        echo 'simulated concurrent push' >&2
        exit 1
      fi
    SH
    File.chmod(0o755, hook)
    calls
  end

  def test_retry_publishes_on_top_of_a_concurrent_commit
    competing = competing_commit([['AdaptyLogger', '1.0.0', AdaptyPods.expected_source('tag', '1.0.0', @sha)]])
    calls = race_on_first_push(competing)
    out, err, status = push(stage)
    assert status.success?, err
    assert_includes err, 'retrying (2/3)'
    assert_equal 2, File.readlines(calls).size
    assert_equal ['[Add] Adapty pods (9.9.9)', 'competing', 'init'], log
    assert_equal competing, git("--git-dir=#{@specs}", 'rev-parse', 'main^').strip
    assert published?('AdaptyLogger', '1.0.0')
    assert(AdaptyPods::ORDER.all? { |pod| published?(pod, '9.9.9') })
    assert_includes out, "Published 9.9.9 (tag 9.9.9, #{@sha}): #{AdaptyPods::ORDER.join(' ')}"
  end

  def test_retry_skips_pods_a_concurrent_commit_already_published
    source = AdaptyPods.expected_source('tag', '9.9.9', @sha)
    competing = competing_commit([['AdaptyLogger', '9.9.9', source]])
    calls = race_on_first_push(competing)
    out, err, status = push(stage)
    assert status.success?, err
    assert_includes err, 'retrying (2/3)'
    assert_equal 2, File.readlines(calls).size
    assert_includes out, 'skip: AdaptyLogger 9.9.9'
    assert_equal ['[Add] Adapty pods (9.9.9)', 'competing', 'init'], log
    added = git("--git-dir=#{@specs}", 'diff', '--name-only', 'main^', 'main').lines.map(&:strip)
    assert_equal(AdaptyPods::ORDER.drop(1).map { |pod| AdaptyPods.spec_path(pod, '9.9.9') }.sort, added.sort)
    assert_includes out, "Published 9.9.9 (tag 9.9.9, #{@sha}): #{AdaptyPods::ORDER.drop(1).join(' ')}"
  end

  def test_commit_body_has_run_url
    env = { 'GITHUB_SERVER_URL' => 'https://github.com', 'GITHUB_REPOSITORY' => 'adaptyteam/AdaptySDK-iOS', 'GITHUB_RUN_ID' => '42' }
    push(stage, env: env)
    body = git("--git-dir=#{@specs}", 'log', '-1', '--format=%b', 'main')
    assert_includes body, "tag 9.9.9 (#{@sha})"
    assert_includes body, 'https://github.com/adaptyteam/AdaptySDK-iOS/actions/runs/42'
  end

  def test_verify_prints_manifest
    out, err, status = run_script('verify', '--from', stage)
    assert status.success?, err
    assert_equal '9.9.9', JSON.parse(out)['version']
  end

  def test_unknown_command
    _out, err, status = run_script('frobnicate')
    refute status.success?
    assert_includes err, 'unknown argument: frobnicate'
  end

  def test_push_needs_from
    _out, err, status = run_script('push')
    refute status.success?
    assert_includes err, '--from'
  end
end
