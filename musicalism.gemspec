# -*- encoding: utf-8 -*-
require File.expand_path('../lib/musicalism/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yann Marquet"]
  gem.email         = ["ymarquet@gmail.com"]
  gem.description   = %q{Notes and scales abstraction library}
  gem.summary       = %q{Notes and scales abstraction library}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "musicalism"
  gem.require_paths = ["lib"]
  gem.version       = Musicalism::VERSION

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'ZenTest'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rake'
end
