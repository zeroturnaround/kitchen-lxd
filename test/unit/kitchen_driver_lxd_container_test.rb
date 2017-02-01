require_relative 'test_helper'
require 'logger'

module Kitchen
	module Driver
		module UnitTest
			class ContainerTest < Minitest::Test

				RUNNING_CONTAINER = '[{"architecture":"x86_64","created_at":"2017-02-01T07:40:47Z","device'\
					's":{"lxdbr0":{"nictype":"bridged","parent":"lxdbr0","type":"nic"},"root":{"path":"/","t'\
					'ype":"disk"}},"ephemeral":false,"last_used_at":"2017-02-01T09:00:45.624'\
					'028767Z","name":"c1","profiles":["default"],"stateful":false,"status":"Running","status'\
					'_code":103,"state":{"status":"Running","status_code":103,"cpu":{"usage":31066811},"disk'\
					'":{},"memory":{"usage":954368,"usage_peak":1503232,"swap_usage":0,"swap_usage_peak":0},'\
					'"network":{"eth0":{"addresses":[{"family":"inet6","address":"fe80::216:3eff:fea0:74cd",'\
					'"netmask":"64","scope":"link"}],"counters":{"bytes_received":90,"bytes_sent":90,"packet'\
					's_received":1,"packets_sent":1},"hwaddr":"00:16:3e:a0:74:cd","host_name":"vethPGTJCQ","'\
					'mtu":1500,"state":"up","type":"broadcast"},"lo":{"addresses":[{"family":"inet","address'\
					'":"127.0.0.1","netmask":"8","scope":"local"},{"family":"inet6","address":"::1","netmask'\
					'":"128","scope":"local"}],"counters":{"bytes_received":0,"bytes_sent":0,"packets_receiv'\
					'ed":0,"packets_sent":0},"hwaddr":"","host_name":"","mtu":65536,"state":"up","type":"loo'\
					'pback"}},"pid":28686,"processes":12},"snapshots":[]}]'

				RUNNING_CONTAINER_WITH_NETWORK = '[{"architecture":"x86_64","created_at":"2017-01-29T06:38'\
					':28Z","devices":{"lxdbr0":{"nictype":"bridged","parent":"lxdbr0","type":"nic"},"root":{'\
					'"path":"/","type":"disk"}},"ephemeral":false,"last_used_at":"2017-01'\
					'-29T06:38:33.865104263Z","name":"java6-kitchen-xenial64","profiles":["default"],"state'\
					'ful":false,"status":"Running","status_code":103,"state":{"status":"Running","status_co'\
					'de":103,"cpu":{"usage":3102020614},"disk":{},"memory":{"usage":12607488,"usage_peak":5'\
					'2240384,"swap_usage":0,"swap_usage_peak":0},"network":{"eth0":{"addresses":[{"family":'\
					'"inet","address":"10.0.4.46","netmask":"24","scope":"global"},{"family":"inet6","addre'\
					'ss":"fe80::216:3eff:fe3c:39e3","netmask":"64","scope":"link"}],"counters":{"bytes_rece'\
					'ived":1092280,"bytes_sent":56948,"packets_received":5775,"packets_sent":297},"hwaddr":'\
					'"00:16:3e:3c:39:e3","host_name":"vethD2UOSY","mtu":1500,"state":"up","type":"broadcast'\
					'"},"lo":{"addresses":[{"family":"inet","address":"127.0.0.1","netmask":"8","scope":"lo'\
					'cal"},{"family":"inet6","address":"::1","netmask":"128","scope":"local"}],"counters":{'\
					'"bytes_received":0,"bytes_sent":0,"packets_received":0,"packets_sent":0},"hwaddr":"","'\
					'host_name":"","mtu":65536,"state":"up","type":"loopback"}},"pid":22602,"processes":10}'\
					',"snapshots":[]}]'

				INITIALISED_CONTAINER = '[{"architecture":"x86_64","created_at":"2017-02-01T07:40:47'\
					'Z","devices":{"root":{"path":"/","type":"disk"}},"ephemeral":false,"last_used_at":"197'\
					'0-01-01T00:00:00Z","name":"c1","profiles":["default"],"stateful":false,"status":"Stopp'\
					'ed","status_code":102,"state":null,"snapshots":[]}]'

				INITIALISED_CONTAINER_WITH_NETWORK = '[{"architecture":"x86_64","created_at":"2017-02-01T'\
					'07:40:47Z","devices":{"lxdbr0":{"nictype":"bridged","parent":"lxdbr0","type":"nic"},"r'\
					'oot":{"path":"/","type":"disk"}},"ephemeral":false,"last_used_at":"1970-01-01T0'\
					'0:00:00Z","name":"c1","profiles":["default"],"stateful":false,"status":"Stopped","statu'\
					's_code":102,"state":null,"snapshots":[]}]'

				def setup
					Lxd::Container.any_instance.expects( :run_command ).
						with( 'lxc list c1 --format json' ).once.returns( '[]' )
					@subj = Lxd::Container.new( 'c1', 'image1', ::Logger.new( StringIO.new ) )
				end

				def test_constructor
					assert_equal 'c1', @subj.instance_variable_get( :@name )
					assert_equal 'image1', @subj.instance_variable_get( :@image )
					assert_nil @subj.state
				end

				def test_init_success
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).once.
						returns( INITIALISED_CONTAINER )
					@subj.expects( :run_command ).with( 'lxc init image1 c1' ).once
					@subj.init
					assert_equal JSON.parse( INITIALISED_CONTAINER, symbolize_names: true ).first, @subj.state
				end

				def test_init_already_created
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).once.
						returns( INITIALISED_CONTAINER )
					@subj.expects( :run_command ).with( 'lxc init image1 c1' ).never
					
					@subj.send :update_state
					@subj.init
					assert_equal JSON.parse( INITIALISED_CONTAINER, symbolize_names: true ).first, @subj.state
				end

				def test_attach_network_success
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).twice.
						returns( INITIALISED_CONTAINER, INITIALISED_CONTAINER_WITH_NETWORK )
					@subj.expects( :run_command ).with( 'lxc network attach lxdbr0 c1' ).once
					@subj.send :update_state
					@subj.attach_network 'lxdbr0'
					assert_equal JSON.parse( INITIALISED_CONTAINER_WITH_NETWORK, symbolize_names: true ).first,
						@subj.state
				end

				def test_attach_network_already_attached
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).once.
						returns( INITIALISED_CONTAINER_WITH_NETWORK )
					@subj.expects( :run_command ).with( 'lxc network attach lxdbr0 c1' ).never
					@subj.send :update_state
					@subj.attach_network 'lxdbr0'
				end

				def test_start_success
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).twice.
						returns( INITIALISED_CONTAINER_WITH_NETWORK, RUNNING_CONTAINER_WITH_NETWORK )
					@subj.expects( :run_command ).with( 'lxc start c1' ).once
					@subj.send :update_state
					@subj.start
					assert_equal JSON.parse( RUNNING_CONTAINER_WITH_NETWORK, symbolize_names: true ).first, @subj.state
				end

				def test_start_already_running
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).once.
						returns( RUNNING_CONTAINER_WITH_NETWORK )
					@subj.expects( :run_command ).with( 'lxc start c1' ).never
					@subj.send :update_state
					@subj.start
				end

				def test_prepare_ssh_success
					@subj.expects( :run_command ).with( 'lxc exec c1 mkdir -- -p /root/.ssh' )
					@subj.expects( :run_command ).with( 'lxc file push ~/.ssh/id_rsa.pub c1/root/.ssh/authorized_keys' )
					@subj.expects( :run_command ).with( 'lxc exec c1 chown -- root:root /root/.ssh/authorized_keys' )
					@subj.prepare_ssh
				end

				def test_destroy_success
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).twice.
						returns( INITIALISED_CONTAINER_WITH_NETWORK, '[]' )
					@subj.expects( :run_command ).with( 'lxc delete c1 --force' ).once
					@subj.send :update_state
					@subj.destroy
					assert_nil @subj.state
				end

				def test_destroy_not_existing
					@subj.expects( :run_command ).with( 'lxc delete c1 --force' ).never
					@subj.destroy
				end

				def test_wait_for_ipv4_success
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).times( 3 ).
						returns( RUNNING_CONTAINER, RUNNING_CONTAINER, RUNNING_CONTAINER_WITH_NETWORK )
					assert_equal '10.0.4.46', @subj.wait_for_ipv4
				end

				def test_wait_for_ipv4_fail
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).times( 9 ).
						returns( RUNNING_CONTAINER )
					assert_nil @subj.wait_for_ipv4
				end

				def test_running_success
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).
						returns( RUNNING_CONTAINER_WITH_NETWORK )
					@subj.send :update_state
					assert @subj.send( :running? )
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).twice.
						returns( INITIALISED_CONTAINER, INITIALISED_CONTAINER_WITH_NETWORK )
					@subj.send :update_state
					refute @subj.send( :running? )
					@subj.send :update_state
					refute @subj.send( :running? )
				end

				def test_created_success
					refute @subj.send( :created? )
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).
						returns( RUNNING_CONTAINER_WITH_NETWORK )
					@subj.send :update_state
					assert @subj.send( :created? )
				end

				def test_device_attached_success
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).
						returns( INITIALISED_CONTAINER )
					@subj.send :update_state
					refute @subj.send( :device_attached?, 'lxdbr0' )
					@subj.expects( :run_command ).with( 'lxc list c1 --format json' ).twice.
						returns( RUNNING_CONTAINER_WITH_NETWORK, INITIALISED_CONTAINER_WITH_NETWORK )
					@subj.send :update_state
					assert @subj.send( :device_attached?, 'lxdbr0' )
					@subj.send :update_state
					assert @subj.send( :device_attached?, 'lxdbr0' )
					refute @subj.send( :device_attached?, 'lxdbr1' )
				end
			end
		end
	end
end
