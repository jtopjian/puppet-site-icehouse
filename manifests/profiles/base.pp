class site::profiles::base {

  # Hiera
  $users                         = hiera_hash('site::users', {})
  $packages                      = hiera_hash('site::packages', {})
  $packages_gems                 = hiera_hash('site::packages::gems', {})
  $packages_eggs                 = hiera_hash('site::packages::eggs', {})
  $puppet_settings               = hiera_hash('puppet::settings', {})
  $puppet_agent_settings         = hiera_hash('puppet::agent::settings', {})
  $firewall_default_policy_ipv4  = hiera('site::firewall::policy::ipv4', 'drop')
  $firewall_default_policy_ipv6  = hiera('site::firewall::policy::ipv6', 'drop')
  $firewall_purge                = hiera('site::firewall::purge', true)
  $firewall_trusted_ipv4         = hiera_array('site::firewall::trusted::ipv4', [])
  $firewall_trusted_ipv6         = hiera_array('site::firewall::trusted::ipv6', [])
  $firewall_untrusted_ipv4       = hiera_array('site::firewall::untrusted::ipv4', [])
  $firewall_untrusted_ipv6       = hiera_array('site::firewall::untrusted::ipv6', [])
  $firewall_rules                = hiera_hash('site::firewall::rules', {})
  $sysctl_ip_local_reserve_ports = hiera_array('site::network::local_reserve_ports', [])
  $sysctl_settings               = hiera_hash('site::sysctl::settings', {})

  anchor { 'site::profiles::base::begin': } ->
  class { 'bass::users':
    users => $users,
  } ->
  class { 'bass::packages':
    packages => $packages,
    gems     => $packages_gems,
    eggs     => $packages_eggs,
  } ->
  class { 'bass::firewall':
    default_policy_ipv4 => $firewall_default_policy_ipv4,
    default_policy_ipv6 => $firewall_default_policy_ipv6,
    purge               => $firewall_purge,
    trusted_ipv4        => $firewall_trusted_ipv4,
    trusted_ipv6        => $firewall_trusted_ipv6,
    untrusted_ipv4      => $firewall_untrusted_ipv4,
    untrusted_ipv6      => $firewall_untrusted_ipv6,
    rules               => $firewall_rules,
  } ->
  class { 'bass::sysctl':
    ip_local_reserve_ports => $sysctl_ip_local_reserve_ports,
    settings               => $sysctl_settings,
  } ->
  class { 'bass::security_updates': } ->
  class { 'puppet':
    settings => $puppet_settings,
  } ->
  class { 'puppet::agent':
    settings => $puppet_agent_settings,
  } ->
  class { 'site::profiles::l2mesh': } ->
  anchor { 'site::profiles::base::end': }

}
