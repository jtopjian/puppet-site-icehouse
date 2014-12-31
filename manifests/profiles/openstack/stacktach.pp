class site::profiles::openstack::stacktach {

  anchor { 'site::profiles::openstck::stacktach::begin': }
  anchor { 'site::profiles::openstck::stacktach::end': }
  Class {
    require => Anchor['site::profiles::openstck::stacktach::begin'],
    before  => Anchor['site::profiles::openstck::stacktach::end'],
  }

  # Hiera
  $stacktach_environment       = hiera('openstack::stacktach::environment')
  $stacktach_verifier_settings = hiera('openstack::stacktach::verifier::settings')
  $stacktach_worker_settings   = hiera('openstack::stacktach::worker::settings')
  $stacktach_shell_environment = join_keys_to_values($stacktach_environment, '=')

  package { 'libmysqlclient-dev':
    ensure => present,
  }

  group { 'stacktach':
    ensure => present,
  }

  user { 'stacktach':
    ensure     => present,
    gid        => 'stacktach',
    home       => '/var/www/stacktach',
    managehome => true,
    require    => Group['stacktach'],
  }

  class { 'apache': }

  class { 'python':
    version    => 'system',
    pip        => true,
    dev        => true,
    virtualenv => true,
    gunicorn   => true,
  }

  vcsrepo { '/var/www/stacktach/app':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/rackerlabs/stacktach',
    user     => 'stacktach',
    group    => 'stacktach',
    require  => [Class['apache'], User['stacktach']],
  }

  python::virtualenv { '/var/www/stacktach' :
    ensure       => present,
    version      => 'system',
    requirements => '/var/www/stacktach/app/etc/pip-requires.txt',
    systempkgs   => true,
    distribute   => false,
    owner        => 'stacktach',
    group        => 'stacktach',
    cwd          => '/var/www/stacktach/app',
    timeout      => 0,
    require      => [Vcsrepo['/var/www/stacktach/app'], Package['libmysqlclient-dev']],
    notify       => Exec['sync stacktach database'],
  }

  file { '/var/www/stacktach/app/stacktach/wsgi.py':
    ensure  => present,
    owner   => 'stacktach',
    group   => 'stacktach',
    mode    => '0640',
    content => 'from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
',
    require => Vcsrepo['/var/www/stacktach/app'],
  }

  python::gunicorn { 'stacktach':
    ensure     => present,
    virtualenv => '/var/www/stacktach',
    appmodule  => 'stacktach.wsgi',
    dir        => '/var/www/stacktach/app',
    bind       => '[::1]:8000',
    osenv      => $stacktach_environment,
    owner      => 'stacktach',
    group      => 'stacktach',
    require    => [Python::Virtualenv['/var/www/stacktach'], File['/var/www/stacktach/app/stacktach/wsgi.py']],
  }

  file { '/etc/init/stacktach-workers.conf':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/site/profiles/openstack/stacktach/stacktach-workers.conf',
  }

  # Configure verifier settings
  file { '/var/www/stacktach/app/etc/stacktach_verifier_config.json':
    ensure  => present,
    owner   => 'stacktach',
    group   => 'stacktach',
    mode    => '0640',
    content => hash2json($stacktach_verifier_settings),
    #notify => Service['httpd'],
    require => Vcsrepo['/var/www/stacktach/app'],
  }

  # Configure worker settings
  file { '/var/www/stacktach/app/etc/stacktach_worker_config.json':
    ensure  => present,
    owner   => 'stacktach',
    group   => 'stacktach',
    mode    => '0640',
    content => hash2json($stacktach_worker_settings),
    #notify => Service['httpd'],
    require => Vcsrepo['/var/www/stacktach/app'],
  }

  # Services
  # StackTach workers
  #service { 'stacktach-workers':
  #  enable   => true,
  #  ensure   => running,
  #  provider => 'upstart',
  #  require  => File['/etc/init/stacktach-workers.conf'],
  #}

  # Execs
  exec { 'sync stacktach database':
    command     => '/bin/bash ./bin/activate; /var/www/stacktach/bin/python manage.py syncdb --noinput',
    path        => ['/bin', '/usr/bin'],
    environment => $stacktach_shell_environment,
    cwd         => '/var/www/stacktach/app',
    refreshonly => true,
    notify      => Exec['migrate stacktach database'],
  }

  exec { 'migrate stacktach database':
    command     => '/bin/bash ./bin/activate; /var/www/stacktach/bin/python manage.py migrate',
    path        => ['/bin', '/usr/bin'],
    environment => $stacktach_shell_environment,
    cwd         => '/var/www/stacktach/app',
    refreshonly => true,
  }

  apache::vhost { $::fqdn:
    default_vhost => true,
    docroot       => '/var/www',
    proxy_pass    => [
      { 'path'    => '/', url => 'http://[::1]:8000/' },
    ],
  }

  file { '/var/log/stacktach':
    ensure => directory,
    owner  => 'stacktach',
    group  => 'stacktach',
    mode   => '0640',
  }



}
