# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mpd_client/version'

Gem::Specification.new do |gem|
  gem.authors       = ['Anton Maminov']
  gem.email         = ['anton.linux@gmail.com']
  gem.description   = 'Yet another Ruby MPD client library'
  gem.summary       = 'Simple Music Player Daemon library written entirely in Ruby'
  gem.homepage      = 'https://github.com/mamantoha/mpd_client'

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.required_ruby_version = '>= 3.2'
  gem.name          = 'mpd_client'
  gem.require_paths = ['lib']
  gem.version       = MPD::Client::VERSION
  gem.license       = 'MIT'

  gem.metadata['rubygems_mfa_required'] = 'true'
end
