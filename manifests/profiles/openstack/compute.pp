class site::profiles::openstack::compute {

  anchor { 'site::profiles::openstack::compute::begin': }
  anchor { 'site::profiles::openstack::compute::end': }
  Class {
    require => Anchor['site::profiles::openstack::compute::begin'],
    before  => Anchor['site::profiles::openstack::compute::end'],
  }

  # Hiera
  $internal_address     = hiera('network::internal::ip')
  $nova_settings        = hiera('openstack::nova::settings')
  $nova_libvirt_type    = hiera('openstack::nova::compute::libvirt_type')
  $neutron_settings     = hiera('openstack::neutron::settings')
  $neutron_ml2_settings = hiera('openstack::neutron::plugins::ml2::settings')

  # Nova
  class { 'cubbystack::nova':
    settings => $nova_settings,
  }

  class { 'cubbystack::nova::compute': }

  class { 'cubbystack::nova::compute::libvirt':
    libvirt_type => $nova_libvirt_type,
  }

  File_line {
    path    => '/etc/libvirt/libvirtd.conf',
    notify  => Service['libvirt-bin'],
    require => Package['libvirt-bin'],
  }

  file_line { '/etc/libvirt/libvirtd.conf listen_tls':
    line  => 'listen_tls = 0',
    match => 'listen_tls =',
  }

  file_line { '/etc/libvirt/libvirtd.conf listen_tcp':
    line  => 'listen_tcp = 1',
    match => 'listen_tcp =',
  }

  file_line { '/etc/libvirt/libvirtd.conf auth_tcp':
    line   => 'auth_tcp = "none"',
    match  => 'auth_tcp =',
  }

  file_line { '/etc/init/libvirt-bin.conf libvirtd opts':
    path  => '/etc/init/libvirt-bin.conf',
    line  => 'env libvirtd_opts="-d -l"',
    match => 'env libvirtd_opts=',
  }

  file_line { '/etc/default/libvirt-bin libvirtd opts':
    path  => '/etc/default/libvirt-bin',
    line  => 'libvirtd_opts="-d -l"',
    match => 'libvirtd_opts=',
  }

  # Neutron
  $vxlan = {
    'vxlan/local_ip' => $internal_address,
  }

  # merge the two settings
  $neutron_ml2_merged = merge($neutron_ml2_settings, $vxlan)

  class { 'cubbystack::neutron':
    settings => $neutron_settings
  }
  class { 'cubbystack::neutron::plugins::ml2':
    settings => $neutron_ml2_merged
  }
  class { 'cubbystack::neutron::plugins::linuxbridge': }

}
