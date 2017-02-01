require 'rake/clean'
require 'rake/testtask'
require 'rubygems/package_task'

CLEAN << 'doc'

Gem::PackageTask.new( Gem::Specification.load( 'kitchen-lxd.gemspec' ) ) do end

desc 'Install this gem locally.'
task :install, [:user_install] => :gem do |t, args|
	args.with_defaults( user_install: false )
	Gem::Installer.new( "pkg/kitchen-lxd-#{Kitchen::Driver::Lxd::VERSION}.gem",
		user_install: args.user_install ).install
end

namespace :test do
	CLEAN << 'test/coverage'
	CLEAN << 'test/reports'

	Rake::TestTask.new :unit do |t|
		t.verbose = true
		t.warning = true
		t.test_files = FileList["test/unit/*_test.rb"]
	end
end
