#!/usr/bin/env ruby
# Classifies pods of a version against a spec repo checkout: new, skip (published from the same
# source) or conflict (published from another source, or not a readable spec).
require 'json'
require_relative 'pods'

module Classify
  def self.call(repo_dir, version, source, pods = AdaptyPods::ORDER)
    pods.to_h { |pod| [pod, status(repo_dir, pod, version, source)] }
  end

  def self.status(repo_dir, pod, version, source)
    return 'new' unless File.exist?(File.join(repo_dir, 'Specs', pod, version))

    file = File.join(repo_dir, AdaptyPods.spec_path(pod, version))
    return 'conflict' unless File.file?(file)

    spec = JSON.parse(File.read(file))
    return 'conflict' unless spec.is_a?(Hash)

    spec['source'] == source ? 'skip' : 'conflict'
  rescue JSON::ParserError, SystemCallError
    'conflict'
  end
end

if $PROGRAM_NAME == __FILE__
  opts = {}
  args = ARGV.dup
  until args.empty?
    arg = args.shift
    value = args.shift
    abort("#{arg} needs a value") if value.nil? || value.start_with?('--')
    case arg
    when '--repo' then opts[:repo] = value
    when '--version' then opts[:version] = value
    when '--source' then opts[:source] = value
    when '--pods' then opts[:pods] = value.split(',')
    else abort("unknown argument: #{arg}")
    end
  end
  abort('--repo, --version and --source are required') unless opts[:repo] && opts[:version] && opts[:source]

  pods = opts[:pods] || AdaptyPods::ORDER
  unknown = pods - AdaptyPods::ORDER
  abort("unknown pods: #{unknown.join(', ')}") unless unknown.empty?

  begin
    source = JSON.parse(opts[:source])
  rescue JSON::ParserError => e
    abort("--source: #{e.message}")
  end
  Classify.call(opts[:repo], opts[:version], source, pods).each { |pod, status| puts "#{pod} #{status}" }
end
