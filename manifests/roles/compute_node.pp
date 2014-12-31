class site::roles::compute_node {
  contain site::profiles::base
  contain site::profiles::openstack::compute
}
