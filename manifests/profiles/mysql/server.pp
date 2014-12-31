class site::profiles::mysql::server {

  # Hiera
  $root_password = hiera('mysql::root_password')
  $allowed_hosts = hiera('mysql::allowed_hosts', ['127.0.0.1'])

  class { '::mysql::server':
    root_password           => $root_password,
    remove_default_accounts => true,
    restart                 => true,
    override_options        => {
      'mysqld' => {
        'bind_address' => '0.0.0.0',
      }
    },
  }

}
