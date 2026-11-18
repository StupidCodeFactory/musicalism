require File.expand_path('lib/musicalism/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors       = ['Yann Marquet']
  gem.email         = ['ymarquet@gmail.com']
  gem.description   = 'Notes, scales, chords, keys, modulations and the key graph, for live coding and MIDI'
  gem.summary       = 'Music theory in plain Ruby: keys, chords and the paths between them'
  gem.homepage      = 'https://github.com/StupidCodeFactory/musicalism'
  gem.required_ruby_version = '>= 4.0'

  gem.files         = Dir['lib/**/*.rb', 'README.md', 'LICENSE']
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'musicalism'
  gem.require_paths = ['lib']
  gem.version       = Musicalism::VERSION

  gem.add_development_dependency 'debug'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'yard'
end
