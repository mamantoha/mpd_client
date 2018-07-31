require File.expand_path('../lib/mpd_client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Anton Maminov"]
  gem.email         = ["anton.linux@gmail.com"]
  gem.description   = %q{Yet another Ruby MPD client library}
  gem.summary       = %q{Simple Music Player Daemon library written entirely in Ruby}
  gem.homepage      = "https://github.com/mamantoha/mpd_client"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mpd_client"
  gem.require_paths = ["lib"]
  gem.version       = MPD::Client::VERSION
end
