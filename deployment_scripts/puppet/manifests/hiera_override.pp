notice('fuel-plugin-emailnotifyd: hiera_override.pp')
$plugin_hash      = hiera('fuel-plugin-emailnotifyd')
$emailnotifyd_vip = $plugin_hash['emailnotifyd_vip']
$hiera_dir              = '/etc/hiera/plugins'
$plugin_name            = 'fuel-plugin-emailnotifyd'
$plugin_yaml            = "${plugin_name}.yaml"
$network_scheme   = hiera_hash('network_scheme')
$network_metadata = hiera_hash('network_metadata')
prepare_network_config($network_scheme)
$emailnotifyd_nodes = get_nodes_hash_by_roles($network_metadata, ['emailnotifyd'])
$nodes_array = values($emailnotifyd_nodes)
$emailnotifyd_nodes_map   = get_node_to_ipaddr_map_by_network_role($emailnotifyd_nodes, 'emailnotifyd_public_vip')
$ip_nodes =sort(values($emailnotifyd_nodes_map))

$calculated_content = inline_template('
emailnotifyd_nodes:
<% @ip_nodes.each do |x| -%>
    - "<%= x %>"
<% end -%>

vip__emailnotifyd: $emailnotifyd_vip

network_metadata:
  vips:
    emailnotifyd:
      ipaddr: <%= @emailnotifyd_vip%>
      is_user_defined: false
      namespace: haproxy
      network_role: kibana
      node_roles:
      - Emailnotifyd
      vendor_specific: null
')

  file { "${hiera_dir}/${plugin_yaml}":
    ensure  => file,
    content => "${calculated_content}",
  }

  package { 'ruby-deep-merge':
    ensure  => 'installed',
  }

