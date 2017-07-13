class emailnotifyd {

  Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
  notice('MODULAR: emailnotifyd/init.pp')

  package { 'emailnotifyd':
    ensure => 'latest',
  }
  package { 'libapache2-mod-wsgi':
    ensure => 'latest',
  }

  $plugin_hash = hiera('fuel-plugin-emailnotifyd')
  $cc_checkbox = pick($plugin_hash['cc_checkbox'])
  $subject   = pick($plugin_hash['subject'], 'VM {vmname} feels bad')
  $body      = pick($plugin_hash['body'], 'Alarm')
  $host      = pick($plugin_hash['host'], '')
  $user      = pick($plugin_hash['user'], '')
  $port      = pick($plugin_hash['port'], '')
  $passwd    = pick($plugin_hash['passwd'], '')
  $from_addr = pick($plugin_hash['from_addr'], 'default@domain.com')
  if cc_checkbox == true {
    $cc_addr   = pick($plugin_hash['cc_addr'], '')
  }

  file { '/etc/emailnotifyd/emailnotifyd.conf':
  	content => template('emailnotifyd/emailnotifyd.conf.erb')
  }

  Package['libapache2-mod-wsgi'] ->  Package['emailnotifyd'] -> File['/etc/emailnotifyd/emailnotifyd.conf']
}
