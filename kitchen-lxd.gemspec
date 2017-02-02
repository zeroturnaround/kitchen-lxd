# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require_relative 'lib/kitchen/driver/version'

Gem::Specification.new do |s|
	s.name = 'kitchen-lxd'
	s.version = Kitchen::Driver::LXD_VERSION
	s.authors = ['Juri Timošin']
	s.email = ['draco.ater@gmail.com', 'juri.timoshin@zeroturnaround.com']
	s.summary = 'An Lxd driver for Test Kitchen.'
	s.description = 'Kitchen::Driver::Lxd - an Lxd driver for Test Kitchen.'
	s.homepage = 'https://github.com/zeroturnaround/kitchen-lxd'
	s.license = 'Apache-2.0'
	s.date = '2017-01-30'
	
	s.files = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*']
	s.require_path = 'lib'

	s.required_ruby_version = '~> 2.0'

	s.add_dependency 'test-kitchen', '~> 1.14'

	s.add_development_dependency 'rake', '~> 12.0'
	s.add_development_dependency 'minitest', '~> 5.5'
	s.add_development_dependency 'simplecov', '~> 0.10'
end
