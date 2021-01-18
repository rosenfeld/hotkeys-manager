# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'global_hotkeys_manager/version'

SINATRA_VERSION = '2.1.0'

Gem::Specification.new do |spec|
  spec.name          = 'global_hotkeys_manager'
  spec.version       = GlobalHotkeysManager::VERSION
  spec.authors       = ['Rodrigo Rosenfeld Rosas']
  spec.email         = ['rr.rosas@gmail.com']

  spec.summary       = %q{Global Hotkeys Management for Linux/X11 with a web interface}
  spec.description   = %q{Integrates with command line tools like xbindkeys and xdotool to assign global hotkeys to toggle the visibility of any captured window}
  spec.homepage      = 'https://github.com/rosenfeld/hotkeys-manager'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'sinatra', SINATRA_VERSION
  spec.add_development_dependency 'sinatra-contrib', SINATRA_VERSION

  spec.add_development_dependency 'bundler', '~> 2.2.3'
  spec.add_development_dependency 'rake', '~> 13.0.3'
end
