# TODO: rewrite
class site::roles::swift_node {

  anchor { 'site::roles:swift_node': }
  Class { require => Anchor['site::roles:swift_node'] }

  # Determine the IP address
  $ip = hiera('network::internal::ip')

  $swift_disks = hiera('openstack::swift::disks')

  package { 'xfsprogs':
    ensure => latest,
  }

  file { '/srv/node':
    ensure => directory,
    owner  => 'swift',
    group  => 'swift',
    mode   => '0644',
  }

  cubbystack::functions::create_swift_device { $swift_disks:
    swift_zone => $::swift_zone,
    ip         => $ip,
    require    => [File['/srv/node'], Package['xfsprogs']],
  }

  class { 'site::profiles:openstack::common::users': }
  class { 'cubbystack::swift':
    settings => hiera('openstack::swift::settings'),
    require  => Class['site::profiles:openstack::common::users'],
  }
  class { 'site::profiles:openstack::swift::rsync':
    require  => Class['site::profiles:openstack::common::users'],
  }
  class { 'site::profiles:openstack::swift::account':
    require  => Class['site::profiles:openstack::common::users'],
  }
  class { 'site::profiles:openstack::swift::container':
    require  => Class['site::profiles:openstack::common::users'],
  }
  class { 'site::profiles:openstack::swift::object':
    require  => Class['site::profiles:openstack::common::users'],
  }

}
