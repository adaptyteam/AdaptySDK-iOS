#!/usr/bin/env ruby
# Verifies a staged artifact before it is pushed: regular files only, exactly the manifest and the
# manifest's specs, each spec's name/version/source matching the manifest, and the manifest matching
# the CI run when EXPECTED_* are set. Prints the manifest as JSON on success.
require 'json'
require 'find'
require_relative 'pods'

class VerifyError < StandardError; end

module VerifyArtifact
  SHA = /\A[0-9a-f]{40}\z/.freeze
  VERSION = /\A\d+\.\d+\.\d+(-[0-9A-Za-z.]+)?\z/.freeze

  def self.call(dir, expected = {})
    dir = File.expand_path(dir)
    manifest = read_json(dir, 'manifest.json')
    check_manifest(manifest)
    check_expected(manifest, expected)
    version = manifest['version']
    check_files(dir, ['manifest.json'] + manifest['pods'].map { |pod| AdaptyPods.spec_path(pod, version) })
    source = AdaptyPods.expected_source(manifest['mode'], manifest['ref'], manifest['sha'])
    manifest['pods'].each { |pod| check_spec(read_json(dir, AdaptyPods.spec_path(pod, version)), pod, version, source) }
    manifest
  end

  def self.check_manifest(manifest)
    reject('manifest must be an object') unless manifest.is_a?(Hash)
    version = manifest['version']
    reject("manifest: invalid version #{version.inspect}") unless version.is_a?(String) && version =~ VERSION && !version.include?('..')
    reject('manifest: mode must be tag or commit') unless %w[tag commit].include?(manifest['mode'])
    reject('manifest: ref must be a non-empty string') unless manifest['ref'].is_a?(String) && !manifest['ref'].empty?
    reject('manifest: sha must be a 40-character hex SHA') unless manifest['sha'].is_a?(String) && manifest['sha'] =~ SHA
    if manifest['mode'] == 'tag' && manifest['ref'] != version
      reject("manifest: tag #{manifest['ref']} does not match version #{version}")
    end
    pods = manifest['pods']
    reject('manifest: pods must be a non-empty array') unless pods.is_a?(Array) && !pods.empty?
    unknown = pods - AdaptyPods::ORDER
    reject("manifest: unknown pods: #{unknown.join(', ')}") unless unknown.empty?
    reject('manifest: duplicate pods') unless pods.uniq.size == pods.size
  end

  def self.check_expected(manifest, expected)
    return if expected.values.all?(&:nil?)

    missing = %i[sha mode ref].select { |key| expected[key].nil? || expected[key].empty? }
    reject("expected #{missing.join(', ')} not set") unless missing.empty?
    reject("manifest sha #{manifest['sha']} is not the run's #{expected[:sha]}") unless manifest['sha'] == expected[:sha]
    reject("manifest mode #{manifest['mode']} is not the run's #{expected[:mode]}") unless manifest['mode'] == expected[:mode]
    if manifest['mode'] == 'tag' && manifest['ref'] != expected[:ref]
      reject("manifest tag #{manifest['ref']} is not the run's #{expected[:ref]}")
    end
  end

  def self.check_files(dir, allowed)
    found = []
    Find.find(dir) do |path|
      next if path == dir

      rel = path.delete_prefix("#{dir}/")
      stat = File.lstat(path)
      if stat.symlink? || !(stat.file? || stat.directory?)
        reject("#{rel}: not a regular file")
      elsif stat.file?
        found << rel
      end
    end
    extra = found - allowed
    missing = allowed - found
    reject("unexpected files: #{extra.sort.join(', ')}") unless extra.empty?
    reject("missing files: #{missing.sort.join(', ')}") unless missing.empty?
  end

  def self.check_spec(spec, pod, version, source)
    reject("#{pod}: spec must be an object") unless spec.is_a?(Hash)
    reject("#{pod}: name is #{spec['name'].inspect}") unless spec['name'] == pod
    reject("#{pod}: version is #{spec['version'].inspect}, expected #{version}") unless spec['version'] == version
    reject("#{pod}: source #{JSON.generate(spec['source'])} is not #{JSON.generate(source)}") unless spec['source'] == source
  end

  def self.read_json(dir, rel)
    JSON.parse(File.read(File.join(dir, rel)))
  rescue Errno::ENOENT
    reject("missing #{rel}")
  rescue JSON::ParserError => e
    reject("#{rel}: #{e.message}")
  end

  def self.reject(message)
    raise VerifyError, message
  end
end

if $PROGRAM_NAME == __FILE__
  abort('usage: verify_artifact.rb DIR') unless ARGV.size == 1
  expected = { sha: ENV['EXPECTED_SHA'], mode: ENV['EXPECTED_MODE'], ref: ENV['EXPECTED_REF'] }
  begin
    puts JSON.generate(VerifyArtifact.call(ARGV[0], expected))
  rescue VerifyError => e
    abort("verify: #{e.message}")
  end
end
