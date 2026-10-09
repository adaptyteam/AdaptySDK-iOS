#!/usr/bin/env ruby
# Reads a podspec JSON on stdin and prints it with `source` pinned to a commit,
# for versions that have no tag in AdaptySDK-iOS. Without --commit prints it unchanged.
require 'json'

def rewrite_source(spec, commit)
  return spec if commit.nil?

  source = spec['source']
  git = source['git'] if source.is_a?(Hash)
  raise ArgumentError, "#{spec['name']}: source has no git URL" if git.nil?

  spec.merge('source' => { 'git' => git, 'commit' => commit })
end

if $PROGRAM_NAME == __FILE__
  commit = nil
  args = ARGV.dup
  until args.empty?
    arg = args.shift
    case arg
    when '--commit'
      commit = args.shift
      abort('--commit needs a SHA') if commit.nil? || commit.start_with?('-')
    else abort("unknown argument: #{arg}")
    end
  end

  begin
    spec = JSON.parse($stdin.read)
    abort('podspec JSON must be an object') unless spec.is_a?(Hash)
    puts JSON.pretty_generate(rewrite_source(spec, commit))
  rescue ArgumentError, JSON::ParserError => e
    abort(e.message)
  end
end
