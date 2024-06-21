# -*- encoding: utf-8 -*-
require File.expand_path('../lib/traquitana/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Eustaquio Rangel']
  gem.email         = ['eustaquiorangel@gmail.com']
  gem.description   = %q{Simple tool for deploy Rails apps}
  gem.summary       = %q{Just a simple tool to deploy Rails apps with SSH and some shell scripts}
  gem.homepage      = 'http://github.com/taq/traquitana'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'traquitana'
  gem.require_paths = ['lib']
  gem.version       = Traquitana::VERSION

  gem.add_dependency('highline', ['>= 0'])
  gem.add_dependency('net-scp', ['>= 0'])
  gem.add_dependency('net-ssh', ['>= 0'])
  gem.add_dependency('ed25519', ['>= 0'])
  gem.add_dependency('bcrypt_pbkdf', ['>= 0'])
  gem.add_dependency('rubyzip', ['>= 2.0.0'])

  gem.license = 'GPL-2.0'

  gem.signing_key = '/home/taq/.gemcert/gem-private_key.pem'
  gem.cert_chain  = ['gem-public_cert.pem']
end
