require 'kitchen'
require 'json'

module Kitchen
	module Driver
		class Lxd < Kitchen::Driver::Base
			class Container
				include ShellOut
				include Logging

				attr_reader :logger
				attr_reader :state

				def initialize( name, image, logger )
					@name = name
					@image = image
					@logger = logger
					update_state
				end

				def init
					unless created?
						run_command "lxc init #@image #@name"
						update_state
					end
				end

				def attach_network( network )
					unless device_attached? network
						run_command "lxc network attach #{network} #@name"
						update_state
					end
				end

				def start
					unless running?
						run_command "lxc start #@name"
						update_state
					end
				end

				def prepare_ssh
					run_command "lxc exec #@name mkdir -- -p /root/.ssh"
					run_command "lxc file push ~/.ssh/id_rsa.pub #@name/root/.ssh/authorized_keys"
					run_command "lxc exec #@name chown -- root:root /root/.ssh/authorized_keys"
				end

				def destroy
					if created?
						run_command "lxc delete #@name --force"
						update_state
					end
				end

				def wait_for_ipv4
					info 'Wait for network to become ready.'
					9.times do
						update_state
						inet = @state[:state][:network][:eth0][:addresses].detect do |i|
							i[:family] == 'inet'
						end
						return inet[:address] if inet
						sleep 1 unless defined?( Minitest )
					end
					nil
				end

				private

				def update_state
					@state = JSON.parse( run_command( "lxc list #@name --format json" ),
						symbolize_names: true ).first
				end

				def running?
					@state[:status] == 'Running'
				end

				def created?
					!@state.nil?
				end

				def device_attached?( network )
					@state[:devices] and @state[:devices][network.to_sym]
				end
			end
		end
	end
end
