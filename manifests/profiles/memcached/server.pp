class site::profiles::memcached::server {

  anchor { 'site::profiles::memcached::server::begin': }
  anchor { 'site::profiles::memcached::server::end': }
  Class {
    require => Anchor['site::profiles::memcached::server::begin'],
    before  => Anchor['site::profiles::memcached::server::end'],
  }

  # Hiera
  $listen_ip = hiera('memcached::listen_ip', '127.0.0.1')

  class { '::memcached':
    listen_ip => $listen_ip,
  }

  case $::operatingsystem {
    'Ubuntu': {
      package { 'python-memcache':
        ensure => latest,
      }
    }
  }

}
