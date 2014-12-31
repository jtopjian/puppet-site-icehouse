# TODO: rewrite
class site::roles::swift_proxy {

  anchor { 'site::roles::swift_proxy': }
  Class { require => Anchor['site::roles::swift_proxy'] }

  class { 'site::profiles::openstack::common::users': }
  class { 'site::profiles::openstack::common::memcached': }
  class { 'cubbystack::swift':
    settings => hiera('openstack::swift::settings'),
    require  => Class['site::profiles::openstack::common::users'],
  }
  class { 'site::profiles::openstack::swift::rsync':
    require  => Class['site::profiles::openstack::common::users']
  }
  class { 'site::profiles::openstack::swift::rings':
    require  => Class['site::profiles::openstack::common::users']
  }
  class { 'cubbystack::swift::proxy':
    settings => hiera('openstack::swift::proxy::settings'),
    require  => Class['site::profiles::openstack::common::users']
  }

  # Extra packages
  $packages = ['swift-plugin-s3', 'python-keystone', 'python-keystoneclient']
  package { $packages:
    ensure => latest,
  }

  # sets up an rsync service that can be used to sync the ring DB
  rsync::server::module { 'swift_server':
    path            => '/etc/swift',
    lock_file       => '/var/lock/swift_server.lock',
    uid             => 'swift',
    gid             => 'swift',
    max_connections => 5,
    read_only       => true,
  }

}
