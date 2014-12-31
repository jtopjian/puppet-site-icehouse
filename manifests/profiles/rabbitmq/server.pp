class site::profiles::rabbitmq::server {

  anchor { 'site::profiles::rabbitmq::server::begin': }
  anchor { 'site::profiles::rabbitmq::server::end': }
  Class {
    require => Anchor['site::profiles::rabbitmq::server::begin'],
    before  => Anchor['site::profiles::rabbitmq::server::end']
  }

  class { '::rabbitmq::server':
    delete_guest_user => true,
  }

}
