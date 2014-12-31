class site::roles::cloud_controller {

  contain site::profiles::base
  contain site::profiles::mysql::server
  contain site::profiles::rabbitmq::server
  contain site::profiles::memcached::server
  contain site::profiles::openstack::controller

}
