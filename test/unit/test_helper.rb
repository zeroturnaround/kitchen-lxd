require 'simplecov'

SimpleCov.start do
	add_filter '/test/'
	coverage_dir 'test/coverage/unit'
end

require 'minitest/autorun'
require 'mocha/setup'

require_relative '../../lib/kitchen/driver/lxd'
