# -*- encoding: utf-8 -*-
#
# Author:: Juri Timošin (<draco.ater@gmail.com>)
#
# Copyright (C) 2017, Juri Timošin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'kitchen'
require_relative 'lxd/container'

module Kitchen
	module Driver
		# Lxd driver for Kitchen.
		#
		# @author Juri Timošin <draco.ater@gmail.com>
		class Lxd < Kitchen::Driver::Base
			kitchen_driver_api_version 2

			default_config( :image ){|driver| driver.instance.platform.name }
			default_config( :container ){|driver| driver.instance.name }

			attr_accessor :container

			def create( state )
				container.init
				container.attach_network 'lxdbr0'
				container.start
				container.prepare_ssh

				state[:hostname] = container.wait_for_ipv4
				instance.transport.connection( state ).wait_until_ready
			end

			def destroy( state )
				instance.transport.connection( state ).close
				state.delete :hostname
				container.destroy
			end

			private

			def container
				@container = Lxd::Container.new( config[:container], config[:image], logger ) if @container.nil?
				@container
			end
		end
	end
end
