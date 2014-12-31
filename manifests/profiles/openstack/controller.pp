class site::profiles::openstack::controller {

  anchor { 'site::profiles::openstack::controller::begin': }
  anchor { 'site::profiles::openstack::controller::end': }
  Class {
    require => Anchor['site::profiles::openstack::controller::begin'],
    before  => Anchor['site::profiles::openstack::controller::end']
  }

  # Hiera
  $internal_ip               = hiera('network::internal::ip', $::ipaddress_eth0)
  $external_ip               = hiera('network::external::ip', $::ipaddress_eth0)
  $mysql_allowed_hosts       = hiera('openstack::mysql::allowed_hosts')
  $mysql_keystone_password   = hiera('openstack::keystone::mysql::password')
  $mysql_glance_password     = hiera('openstack::glance::mysql::password')
  $mysql_nova_password       = hiera('openstack::nova::mysql::password')
  $mysql_cinder_password     = hiera('openstack::cinder::mysql::password')
  $mysql_neutron_password    = hiera('openstack::neutron::mysql::password')
  $mysql_heat_password       = hiera('openstack::heat::mysql::password')
  $mysql_stacktach_password  = hiera('openstack::stacktach::mysql::password')
  $rabbitmq_userid           = hiera('openstack::rabbitmq::userid', 'openstack')
  $rabbitmq_password         = hiera('openstack::rabbitmq::password')
  $rabbitmq_vhost            = hiera('openstack::rabbitmq::vhost', '/')
  $keystone_settings         = hiera('openstack::keystone::settings')
  $openstack_region          = hiera('openstack::region', 'RegionOne')
  $glance_api_settings       = hiera('openstack::glance::api::settings')
  $glance_registry_settings  = hiera('openstack::glance::registry::settings')
  $glance_cache_settings     = hiera('openstack::glance::cache::settings')
  $nova_settings             = hiera('openstack::nova::settings')
  $cinder_settings           = hiera('openstack::cinder::settings')
  $neutron_server_settings   = hiera('openstack::neutron::settings')
  $neutron_dhcp_settings     = hiera('openstack::neutron::dhcp::settings')
  $neutron_l3_settings       = hiera('openstack::neutron::l3::settings')
  $neutron_metadata_settings = hiera('openstack::neutron::metadata::settings')
  $neutron_ml2_settings      = hiera('openstack::neutron::plugins::ml2::settings')
  $heat_settings             = hiera('openstack::heat::settings')
  $horizon_config_file       = hiera('openstack::horizon::config_file', 'puppet:///modules/site/profiles/openstack/horizon/local_settings.py')

  # MySQL
  include mysql::bindings
  include mysql::bindings::python

  cubbystack::functions::create_mysql_db { 'keystone':
    user          => 'keystone',
    password      => $mysql_keystone_password,
    allowed_hosts => $mysql_allowed_hosts,
    before        => Class['cubbystack::keystone'],
  }

  cubbystack::functions::create_mysql_db { 'glance':
    user          => 'glance',
    password      => $mysql_glance_password,
    allowed_hosts => $mysql_allowed_hosts,
    before        => Class['cubbystack::glance'],
  }

  cubbystack::functions::create_mysql_db { 'cinder':
    user          => 'cinder',
    password      => $mysql_cinder_password,
    allowed_hosts => $mysql_allowed_hosts,
    before        => Class['cubbystack::cinder'],
  }

  cubbystack::functions::create_mysql_db { 'nova':
    user          => 'nova',
    password      => $mysql_nova_password,
    allowed_hosts => $mysql_allowed_hosts,
    before        => Class['cubbystack::nova'],
  }

  cubbystack::functions::create_mysql_db { 'neutron':
    user          => 'neutron',
    password      => $mysql_neutron_password,
    allowed_hosts => $mysql_allowed_hosts,
    before        => Class['cubbystack::neutron'],
  }

  cubbystack::functions::create_mysql_db { 'heat':
    user          => 'heat',
    password      => $mysql_heat_password,
    allowed_hosts => $mysql_allowed_hosts,
    before        => Class['cubbystack::heat'],
  }

  cubbystack::functions::create_mysql_db { 'stacktach':
    user          => 'stacktach',
    password      => $mysql_stacktach_password,
    allowed_hosts => $mysql_allowed_hosts,
  }

  # RabbitMQ
  rabbitmq_user { $rabbitmq_userid:
    admin    => true,
    password => $rabbitmq_password,
  }

  rabbitmq_user_permissions { "${rabbitmq_userid}@${rabbitmq_vhost}":
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
  }

  rabbitmq_vhost { $rabbitmq_vhost: }

  # Keystone
  class { 'cubbystack::keystone':
    settings => $keystone_settings,
  }

  cubbystack::functions::create_keystone_endpoint { "${openstack_region}/identity":
    public_url   => "http://${external_ip}:5000/v2.0",
    admin_url    => "http://${external_ip}:35357/v2.0",
    internal_url => "http://${internal_ip}:5000/v2.0",
    service_name => 'OpenStack Identity Service',
    tag          => $openstack_region,
  }

  cubbystack::functions::create_keystone_endpoint { "${openstack_region}/image":
    public_url   => "http://${external_ip}:9292",
    admin_url    => "http://${external_ip}:9292",
    internal_url => "http://${internal_ip}:9292",
    service_name => 'OpenStack Image Service',
    tag          => $openstack_region,
  }

  cubbystack::functions::create_keystone_endpoint { "${openstack_region}/volume":
    public_url   => "http://${external_ip}:8776/v1/%(tenant_id)s",
    admin_url    => "http://${external_ip}:8776/v1/%(tenant_id)s",
    internal_url => "http://${internal_ip}:8776/v1/%(tenant_id)s",
    service_name => 'OpenStack Volume Service',
    tag          => $openstack_region,
  }

  cubbystack::functions::create_keystone_endpoint { "${openstack_region}/compute":
    public_url   => "http://${external_ip}:8774/v2/%(tenant_id)s",
    admin_url    => "http://${external_ip}:8774/v2/%(tenant_id)s",
    internal_url => "http://${internal_ip}:8774/v2/%(tenant_id)s",
    service_name => 'OpenStack Compute Service',
    tag          => $openstack_region,
  }

  cubbystack::functions::create_keystone_endpoint { "${openstack_region}/ec2":
    public_url   => "http://${external_ip}:8773/services/Cloud",
    admin_url    => "http://${external_ip}:8773/services/Cloud",
    internal_url => "http://${internal_ip}:8773/services/Cloud",
    service_name => 'OpenStack EC2 Service',
    tag          => $openstack_region,
  }

  cubbystack::functions::create_keystone_endpoint { "${openstack_region}/network":
    public_url   => "http://${external_ip}:9696",
    admin_url    => "http://${external_ip}:9696",
    internal_url => "http://${internal_ip}:9696",
    service_name => 'OpenStack Networking Service',
    tag          => $openstack_region,
  }

  cubbystack::functions::create_keystone_endpoint { "${openstack_region}/object-store":
    public_url   => "http://${external_ip}:8080/v1/AUTH_%(tenant_id)s",
    admin_url    => "http://${external_ip}:8080",
    internal_url => "http://${internal_ip}:8080/v1/AUTH_%(tenant_id)s",
    service_name => 'OpenStack Object Storage Service',
    tag          => $openstack_region,
  }

  cubbystack::functions::create_keystone_endpoint { "${openstack_region}/orchestration":
    public_url   => "http://${external_ip}:8004/v1/%(tenant_id)s",
    admin_url    => "http://${external_ip}:8004/v1/%(tenant_id)s",
    internal_url => "http://${internal_ip}:8004/v1/%(tenant_id)s",
    service_name => 'OpenStack Orchestration Service',
    tag          => $openstack_region,
  }

  cubbystack::functions::create_keystone_endpoint { "${openstack_region}/cloudformation":
    public_url   => "http://${external_ip}:8000/v1/",
    admin_url    => "http://${external_ip}:8000/v1/",
    internal_url => "http://${internal_ip}:8000/v1/",
    service_name => 'OpenStack Cloudformation Service',
    tag          => $openstack_region,
  }

  cubbystack::functions::create_keystone_endpoint { "${openstack_region}/database":
    public_url   => "http://${external_ip}:8779/v1.0/%(tenant_id)s",
    admin_url    => "http://${external_ip}:8779/v1.0/%(tenant_id)s",
    internal_url => "http://${internal_ip}:8779/v1.0/%(tenant_id)s",
    service_name => 'OpenStack Database Service',
    tag          => $openstack_region,
  }

  # Glance
  class { 'cubbystack::glance': }
  class { 'cubbystack::glance::api':
    settings => $glance_api_settings,
  }
  class { 'cubbystack::glance::registry':
    settings => $glance_registry_settings,
  }
  class { 'cubbystack::glance::cache':
    settings => $glance_cache_settings,
  }
  class { 'cubbystack::glance::db_sync': }

  # Nova
  class { 'cubbystack::nova':
    settings => $nova_settings,
  }
  class { 'cubbystack::nova::api': }
  class { 'cubbystack::nova::cert': }
  class { 'cubbystack::nova::conductor': }
  class { 'cubbystack::nova::objectstore': }
  class { 'cubbystack::nova::scheduler': }
  class { 'cubbystack::nova::vncproxy': }
  class { 'cubbystack::nova::db_sync': }

  ## Generate an openrc file
  cubbystack::functions::create_openrc { '/root/openrc':
    keystone_host  => hiera('openstack::cloud_controller'),
    admin_password => hiera('openstack::keystone::admin::password'),
    admin_tenant   => 'admin',
    region         => $openstack_region,
  }

  # Cinder
  class { 'cubbystack::cinder':
    settings => $cinder_settings,
  }
  class { 'cubbystack::cinder::api': }
  class { 'cubbystack::cinder::scheduler': }
  class { 'cubbystack::cinder::volume': }
  class { 'cubbystack::cinder::db_sync': }

  # Neutron
  # Determine the internal address for vxlan
  $vxlan = {
    'vxlan/local_ip' => $internal_ip,
  }

  # merge the two settings
  $neutron_ml2_merged = merge($neutron_ml2_settings, $vxlan)
  class {'cubbystack::neutron':
      settings => $neutron_server_settings,
  }
  class { 'cubbystack::neutron::dhcp':
      settings => $neutron_dhcp_settings,
  }
  class { 'cubbystack::neutron::l3':
      settings => $neutron_l3_settings,
  }
  class { 'cubbystack::neutron::metadata':
      settings => $neutron_metadata_settings,
  }
  class { 'cubbystack::neutron::plugins::ml2':
      settings => $neutron_ml2_merged,
  }
  class { 'cubbystack::neutron::plugins::linuxbridge': }
  class { 'cubbystack::neutron::server': }

  file_line { '/etc/default/neutron-server NEUTRON_PLUGIN_CONFIG':
    path    => '/etc/default/neutron-server',
    line    => 'NEUTRON_PLUGIN_CONFIG="/etc/neutron/plugins/ml2/ml2_conf.ini"',
    match   => '^NEUTRON_PLUGIN_CONFIG',
    require => Class['cubbystack::neutron::plugins::ml2'],
  }

  # Heat
  class { 'cubbystack::heat':
    settings => $heat_settings,
  }
  class { 'cubbystack::heat::api': }
  class { 'cubbystack::heat::api_cfn': }
  class { 'cubbystack::heat::api_cloudwatch': }
  class { 'cubbystack::heat::engine': }
  class { 'cubbystack::heat::db_sync': }

  # Horizon
  class { 'cubbystack::horizon':
    config_file => $horizon_config_file,
  }

  file_line { 'horizon root url':
    path    => '/etc/apache2/conf-enabled/openstack-dashboard.conf',
    line    => 'WSGIScriptAlias / /usr/share/openstack-dashboard/openstack_dashboard/wsgi/django.wsgi',
    match   => 'WSGIScriptAlias ',
    require => Class['cubbystack::horizon'],
  }

}
