class site::roles::stacktach {
  class { 'site::profiles::base': } ->
  class { 'site::profiles::stacktach': }
}
