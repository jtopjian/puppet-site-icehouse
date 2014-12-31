class site::profiles::l2mesh {

  # Hiera
  $interface      = hiera('l2mesh::interface')
  $tunnel_device  = hiera('l2mesh::tunnel_device')
  $tunnel_ip      = hiera('l2mesh::tunnel_ip')
  $tunnel_netmask = hiera('l2mesh::tunnel_netmask')

  anchor { 'site::profiles::l2mesh::begin': } ->
  class { '::l2mesh':
    interface      => $interface,
    tunnel_device  => $tunnel_device,
    tunnel_ip      => $tunnel_ip,
    tunnel_netmask => $tunnel_netmask,
  } ->
  anchor { 'site::profiles::l2mesh::end': }

}
