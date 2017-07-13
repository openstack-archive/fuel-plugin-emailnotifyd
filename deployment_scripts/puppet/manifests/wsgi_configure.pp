notice('fp-emailnotifyd: wsgi_configure')
Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
file_line {"delete default port":
     path => '/etc/apache2/sites-enabled/wsgi-emailnotifyd.conf',
     line => "Listen 10088",
     ensure => absent,
}
file_line {"replace default virtual host":
     ensure => present,
     path => '/etc/apache2/sites-enabled/wsgi-emailnotifyd.conf',
     line => "<VirtualHost $fqdn:80>",
     match => '^<VirtualHost.*>',
}
file_line {"adding ServerName":
     ensure => present,
     path => '/etc/apache2/sites-enabled/wsgi-emailnotifyd.conf',
     line => "    ServerName $fqdn",
     after => "^<VirtualHost $fqdn:80>.*",
}
exec {"removing Locations":
      command => "sed -i -e '/.*Location.*/d' -e '/.*Require all granted.*/d' /etc/apache2/sites-enabled/wsgi-emailnotifyd.conf",
      path => '/bin/'
}
file_line {"adding port to apache":
     ensure => present,
     path => '/etc/apache2/ports.conf',
     line => "Listen $ipaddress:80",
}
file_line {"removing default 80 port from apache":
     ensure => absent,
     path => '/etc/apache2/ports.conf',
     line => "Listen 80",
}
exec { "Restart apache if present":
    command     => "service apache2 restart",
    onlyif      => "test -f /etc/init.d/apache2",
  }

File_line['delete default port'] -> File_line['replace default virtual host'] ->
File_line['adding ServerName'] -> Exec['removing Locations'] ->
File_line['adding port to apache'] -> File_line['removing default 80 port from apache']->Exec['Restart apache if present']
