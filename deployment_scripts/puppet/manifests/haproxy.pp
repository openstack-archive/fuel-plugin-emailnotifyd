notice('fuel-plugin-emailnotifyd: haproxy.pp')

$plugin_hash      = hiera('fuel-plugin-emailnotifyd')
$emailnotifyd_vip = $plugin_hash['emailnotifyd_vip']
$emailnotifyd_port = $plugin_hash['emailnotifyd_port']
$hiera_dir              = '/etc/hiera/plugins'
$plugin_name            = 'fuel-plugin-emailnotifyd'
$plugin_yaml            = "${plugin_name}.yaml"
$nodes_ips = hiera('emailnotifyd_nodes')
$nodes_names = prefix(range(1, size($nodes_ips)), 'server_')

Openstack::Ha::Haproxy_service {
  internal_virtual_ip  => $internal_virtual_ip,
  server_names        => $nodes_names,
  ipaddresses         => $ipaddresses,
  public              => true,
  public_ssl          => false,
  internal            => false,
  public_virtual_ip => $emailnotifyd_vip,
}

openstack::ha::haproxy_service { 'emailnotifyd':
  order                  => '777',
  listen_port            => $emailnotifyd_port,
  ipaddresses         => $nodes_ips,
  balancermember_port    => $emailnotifyd_port,
  balancermember_options => 'check inter 10s fastinter 2s downinter 3s rise 3 fall 3',
  haproxy_config_options => {
    'option'  => ['httplog', 'http-keep-alive', 'prefer-last-server', 'dontlog-normal'],
    'balance' => 'roundrobin',
    'mode'    => 'http',
  }
}
