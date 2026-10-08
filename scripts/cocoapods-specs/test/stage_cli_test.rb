require 'minitest/autorun'
require 'open3'
require 'tmpdir'
require 'fileutils'

class StageCliTest < Minitest::Test
  SCRIPT = File.expand_path('../publish.sh', __dir__)

  def run_script(*args)
    Open3.capture3('/bin/bash', SCRIPT, *args)
  end

  def test_stage_needs_ref_and_out
    _out, err, status = run_script('stage', '--ref', 'HEAD')
    refute status.success?
    assert_includes err, 'stage needs --ref and --out'
  end

  def test_stage_refuses_existing_out
    Dir.mktmpdir do |dir|
      _out, err, status = run_script('stage', '--ref', 'HEAD', '--out', dir)
      refute status.success?
      assert_includes err, 'already exists'
    end
  end

  def test_stage_rejects_unknown_ref
    Dir.mktmpdir do |dir|
      _out, err, status = run_script('stage', '--ref', 'no-such-ref-xyz', '--out', File.join(dir, 'out'))
      refute status.success?
      assert_includes err, 'unknown ref no-such-ref-xyz'
    end
  end

  def test_stage_flags_need_values
    _out, err, status = run_script('stage', '--ref')
    refute status.success?
    assert_includes err, '--ref needs a value'
  end

  def test_help_lists_stage
    out, _err, status = run_script('--help')
    assert status.success?
    assert_includes out, 'stage --ref REF --out DIR'
  end

  # Only stage needs the iOS checkout and the pod list.
  def test_non_stage_commands_work_outside_a_git_checkout
    Dir.mktmpdir do |dir|
      FileUtils.cp(Dir[File.join(File.dirname(SCRIPT), '*.{sh,rb}')], dir)
      script = File.join(dir, 'publish.sh')
      out, _err, status = Open3.capture3('/bin/bash', script, '--help', chdir: dir)
      assert status.success?
      assert_includes out, 'stage --ref REF --out DIR'

      _out, err, status = Open3.capture3('/bin/bash', script, 'verify', chdir: dir)
      refute status.success?
      assert_includes err, 'verify needs --from DIR'

      _out, err, status = Open3.capture3('/bin/bash', script, 'stage', '--ref', 'HEAD', '--out',
                                         File.join(dir, 'out'), chdir: dir)
      refute status.success?
      assert_includes err, 'not inside a git checkout'
    end
  end

  def test_manual_mode_needs_ref
    _out, err, status = run_script('--specs-url', 'file:///nonexistent.git')
    refute status.success?
    assert_includes err, 'a command or --ref is required'
  end
end
