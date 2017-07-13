notice('fp-emailnotifyd: hosts.pp')
$network_metadata = hiera_hash('network_metadata')
$host_resources = network_metadata_to_hosts($network_metadata,'ex','')
$host_keys=keys($host_resources)

define updateHostsfile {
$network_metadata = hiera_hash('network_metadata')
$host_resources = network_metadata_to_hosts($network_metadata,'ex','')
$node_hash=$host_resources[$name]
$node_values=values($node_hash)
$node_name=$node_values[1]
$node_ip=$node_values[0]
file_line {"$name":
     path => "/etc/hosts",
     line => "$node_ip $name $node_name",
}
}
updateHostsfile{$host_keys:}
