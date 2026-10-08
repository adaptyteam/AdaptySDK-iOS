require 'minitest/autorun'
require 'json'
require 'open3'
require 'tmpdir'
require 'fileutils'
require_relative '../pods'

# Runs `publish.sh stage` against local repos with a fake `pod` first on PATH.
class StageTest < Minitest::Test
  SCRIPTS = File.expand_path('..', __dir__)
  STAGE_REPO = 'adapty-specs-stage'.freeze

  # Implements only what stage calls; logs every invocation as a JSON array.
  FAKE_POD = <<~'RUBY'.freeze
    #!/usr/bin/env ruby
    require 'json'
    require 'fileutils'

    File.open(ENV.fetch('FAKE_POD_LOG'), 'a') { |f| f.puts(JSON.generate(ARGV)) }

    module Pod
      class Spec
        attr_accessor :name, :version, :source

        def initialize
          yield self
        end
      end
    end

    def run!(*cmd)
      system(*cmd) || abort("fake pod: #{cmd.join(' ')} failed")
    end

    case ARGV[0, 2]
    when %w[ipc spec]
      spec = eval(File.read(ARGV[2]), binding, ARGV[2])
      puts JSON.pretty_generate('name' => spec.name, 'version' => spec.version, 'source' => spec.source)
    when %w[repo add]
      name, url, branch = ARGV[2, 3]
      dir = File.join(ENV.fetch('CP_REPOS_DIR'), name)
      FileUtils.mkdir_p(File.dirname(dir))
      run!('git', 'clone', '--quiet', *(branch ? ['--branch', branch] : []), url, dir)
    when %w[repo push]
      name, file = ARGV[2, 2]
      abort('fake pod: only --local-only is supported') unless ARGV.include?('--local-only')
      spec = JSON.parse(File.read(file))
      dir = File.join(ENV.fetch('CP_REPOS_DIR'), name)
      rel = File.join('Specs', spec['name'], spec['version'], "#{spec['name']}.podspec.json")
      abort("fake pod: #{rel} exists") if File.exist?(File.join(dir, rel))
      FileUtils.mkdir_p(File.dirname(File.join(dir, rel)))
      FileUtils.cp(file, File.join(dir, rel))
      message = ARGV.grep(/\A--commit-message=/).first.to_s.sub('--commit-message=', '')
      run!('git', '-C', dir, 'add', rel)
      run!('git', '-C', dir, 'commit', '--quiet', '-m', message)
    else
      abort("fake pod: unsupported #{ARGV.join(' ')}")
    end
  RUBY

  def setup
    @tmp = Dir.mktmpdir
    bin = File.join(@tmp, 'bin')
    FileUtils.mkdir_p(bin)
    File.write(File.join(bin, 'pod'), FAKE_POD)
    File.chmod(0o755, File.join(bin, 'pod'))
    @pod_log = File.join(@tmp, 'pod.log')
    @env = {
      'PATH' => "#{bin}:#{ENV.fetch('PATH')}", 'FAKE_POD_LOG' => @pod_log,
      'GIT_AUTHOR_NAME' => 'Test', 'GIT_AUTHOR_EMAIL' => 'test@example.com',
      'GIT_COMMITTER_NAME' => 'Test', 'GIT_COMMITTER_EMAIL' => 'test@example.com',
      'EXPECTED_SHA' => nil, 'EXPECTED_MODE' => nil, 'EXPECTED_REF' => nil
    }
    @out = File.join(@tmp, 'staged')
    setup_specs_repo
    setup_ios_repo
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  # The default branch is not main, so a clone that ignores the branch sees no specs.
  def setup_specs_repo
    @specs = File.join(@tmp, 'specs.git')
    git('init', '--quiet', '--bare', '--initial-branch=main', @specs)
    seed = File.join(@tmp, 'seed')
    git('clone', '--quiet', @specs, seed)
    FileUtils.mkdir_p(File.join(seed, 'Specs'))
    File.write(File.join(seed, 'Specs', '.gitkeep'), '')
    git('-C', seed, 'add', '.')
    git('-C', seed, 'commit', '--quiet', '-m', 'init')
    git('-C', seed, 'push', '--quiet', 'origin', 'HEAD:refs/heads/main')
    git('-C', seed, 'checkout', '--quiet', '--orphan', 'legacy')
    git('-C', seed, 'rm', '--quiet', '-rf', '.')
    File.write(File.join(seed, 'README'), 'legacy')
    git('-C', seed, 'add', 'README')
    git('-C', seed, 'commit', '--quiet', '-m', 'legacy')
    git('-C', seed, 'push', '--quiet', 'origin', 'HEAD:refs/heads/legacy')
    git("--git-dir=#{@specs}", 'symbolic-ref', 'HEAD', 'refs/heads/legacy')
  end

  # The scripts live inside the fake iOS checkout, so publish.sh resolves it as IOS_REPO.
  def setup_ios_repo
    @ios = File.join(@tmp, 'ios')
    @ios_origin = File.join(@tmp, 'ios.git')
    git('init', '--quiet', '--bare', '--initial-branch=main', @ios_origin)
    git('init', '--quiet', '--initial-branch=main', @ios)
    git('-C', @ios, 'remote', 'add', 'origin', "file://#{@ios_origin}")
    @script = File.join(@ios, 'scripts', 'cocoapods-specs', 'publish.sh')
    FileUtils.mkdir_p(File.dirname(@script))
    FileUtils.cp(Dir[File.join(SCRIPTS, '*.{sh,rb}')], File.dirname(@script))
  end

  def git(*args)
    out, err, status = Open3.capture3(@env, 'git', *args)
    raise "git #{args.join(' ')}: #{err}" unless status.success?

    out
  end

  def podspec(pod, version)
    <<~RUBY
      Pod::Spec.new do |s|
        s.name = '#{pod}'
        s.version = '#{version}'
        s.source = { :git => '#{AdaptyPods::IOS_GIT}', :tag => s.version.to_s }
      end
    RUBY
  end

  # Commits the seven podspecs at `version` (or per-pod `versions`) and optionally pushes main.
  def ios_commit(version, versions: {}, push: true)
    AdaptyPods::ORDER.each do |pod|
      File.write(File.join(@ios, "#{pod}.podspec"), podspec(pod, versions.fetch(pod, version)))
    end
    git('-C', @ios, 'add', '--', '*.podspec')
    git('-C', @ios, 'commit', '--quiet', '--allow-empty', '-m', "podspecs #{version}")
    git('-C', @ios, 'push', '--quiet', 'origin', 'HEAD:refs/heads/main') if push
    git('-C', @ios, 'fetch', '--quiet', 'origin')
    git('-C', @ios, 'rev-parse', 'HEAD').strip
  end

  def tag(name)
    git('-C', @ios, 'tag', '-a', name, '-m', name)
    git('-C', @ios, 'push', '--quiet', 'origin', "refs/tags/#{name}")
  end

  # Adds specs to the spec repo's main as if they were published earlier.
  def publish_existing(pods, version, source)
    clone = File.join(@tmp, 'publisher')
    git('clone', '--quiet', '--branch', 'main', @specs, clone)
    pods.each do |pod|
      path = File.join(clone, AdaptyPods.spec_path(pod, version))
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.pretty_generate('name' => pod, 'version' => version, 'source' => source))
    end
    git('-C', clone, 'add', 'Specs')
    git('-C', clone, 'commit', '--quiet', '-m', 'published earlier')
    git('-C', clone, 'push', '--quiet', 'origin', 'HEAD:refs/heads/main')
  end

  def stage(ref)
    Open3.capture3(@env, '/bin/bash', @script, 'stage', '--ref', ref, '--out', @out,
                   '--ios-url', "file://#{@ios_origin}", '--specs-url', "file://#{@specs}")
  end

  def pod_calls(command = nil)
    calls = File.exist?(@pod_log) ? File.readlines(@pod_log).map { |line| JSON.parse(line) } : []
    command ? calls.select { |args| args[0, 2] == command } : calls
  end

  def staged_spec(pod, version)
    JSON.parse(File.read(File.join(@out, AdaptyPods.spec_path(pod, version))))
  end

  def specs_main_log
    git("--git-dir=#{@specs}", 'log', '--format=%s', 'main').lines.map(&:strip)
  end

  def assert_staged_nothing
    assert_empty pod_calls(%w[repo push])
    refute File.exist?(@out), "#{@out} must not be created"
  end

  def test_tag_mode
    sha = ios_commit('9.9.9')
    tag('9.9.9')
    out, err, status = stage('9.9.9')
    assert status.success?, err
    assert_includes out, "Staged 9.9.9: #{AdaptyPods::ORDER.join(' ')}"

    manifest = JSON.parse(File.read(File.join(@out, 'manifest.json')))
    assert_equal({ 'version' => '9.9.9', 'mode' => 'tag', 'ref' => '9.9.9', 'sha' => sha, 'pods' => AdaptyPods::ORDER },
                 manifest)
    AdaptyPods::ORDER.each do |pod|
      spec = staged_spec(pod, '9.9.9')
      assert_equal [pod, '9.9.9'], [spec['name'], spec['version']]
      assert_equal AdaptyPods.expected_source('tag', '9.9.9', sha), spec['source']
    end

    assert_equal [['repo', 'add', STAGE_REPO, "file://#{@specs}", 'main']], pod_calls(%w[repo add])
    pushes = pod_calls(%w[repo push])
    assert_equal(AdaptyPods::ORDER, pushes.map { |args| File.basename(args[3], '.podspec.json') })
    pushes.each do |args|
      assert_equal STAGE_REPO, args[2]
      assert_includes args, "--sources=#{STAGE_REPO}"
      assert_includes args, '--local-only'
      assert_includes args, '--no-overwrite'
    end
    assert_equal ['init'], specs_main_log
  end

  def test_commit_mode
    sha = ios_commit('9.9.10-SNAPSHOT.1')
    _out, err, status = stage(sha)
    assert status.success?, err

    manifest = JSON.parse(File.read(File.join(@out, 'manifest.json')))
    assert_equal(%w[commit] + [sha, sha], manifest.values_at('mode', 'ref', 'sha'))
    assert_equal AdaptyPods::ORDER, manifest['pods']
    AdaptyPods::ORDER.each do |pod|
      assert_equal({ 'git' => AdaptyPods::IOS_GIT, 'commit' => sha }, staged_spec(pod, '9.9.10-SNAPSHOT.1')['source'])
    end
    assert_equal AdaptyPods::ORDER.size, pod_calls(%w[repo push]).size
  end

  def test_nothing_new
    sha = ios_commit('9.9.9')
    tag('9.9.9')
    publish_existing(AdaptyPods::ORDER, '9.9.9', AdaptyPods.expected_source('tag', '9.9.9', sha))
    out, err, status = stage('9.9.9')
    assert status.success?, err
    assert_includes out, 'Nothing to publish: 9.9.9 is already published from tag 9.9.9'
    assert_staged_nothing
  end

  def test_refuses_pod_published_from_another_source
    sha = ios_commit('9.9.9')
    tag('9.9.9')
    publish_existing(['AdaptyUI'], '9.9.9', AdaptyPods.expected_source('commit', sha, sha))
    _out, err, status = stage('9.9.9')
    refute status.success?
    assert_includes err, 'AdaptyUI 9.9.9 is already published from another source'
    assert_staged_nothing
  end

  def test_refuses_version_drift
    sha = ios_commit('9.9.9', versions: { 'AdaptyUI' => '9.9.8' })
    _out, err, status = stage(sha)
    refute status.success?
    assert_includes err, 'AdaptyUI is 9.9.8, expected 9.9.9 (podspec versions drifted'
    assert_staged_nothing
  end

  def test_refuses_tag_not_matching_version
    ios_commit('9.9.9')
    tag('9.9.8')
    _out, err, status = stage('9.9.8')
    refute status.success?
    assert_includes err, 'tag 9.9.8 does not match podspec version 9.9.9'
    assert_staged_nothing
  end

  def test_refuses_commit_not_on_a_remote_branch
    ios_commit('9.9.9')
    sha = ios_commit('9.9.10-SNAPSHOT.1', push: false)
    _out, err, status = stage(sha)
    refute status.success?
    assert_includes err, "commit #{sha} is not on any remote branch"
    assert_staged_nothing
  end
end
