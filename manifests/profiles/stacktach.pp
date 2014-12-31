class site::profiles::stacktach {

  # Hiera
  $stacktach_db_password     = hiera('openstack::stacktach::mysql::password')
  $stacktach_django_config   = hiera('openstack::stacktach::django::config')
  $stacktach_verifier_config = hiera('openstack::stacktach::verifier::config')
  $stacktach_worker_config   = hiera('openstack::stacktach::worker::config')

  class { 'site::profiles::mysql::server': } ->
  class { 'apache': } ->
  class { '::stacktach::db::mysql':
    db_password => $stacktach_db_password,
  } ->
  class { '::stacktach':
    django_config   => $stacktach_django_config,
    verifier_config => $stacktach_verifier_config,
    worker_config   => $stacktach_worker_config,
  }
}
