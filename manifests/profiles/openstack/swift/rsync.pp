class site::profiles::openstack::swift::rsync {

  anchor { 'site::profiles::openstack::swift::rsync': }
  Class { require => Anchor['site::profiles::openstack::swift::rsync'] }

  # Determine the IP address
  $ip = hiera('network::internal::ip')

  class { 'rsync::server':
    use_xinetd => true,
    address    => $ip,
    use_chroot => 'no'
  }

}
