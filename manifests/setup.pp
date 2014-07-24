# puppet module install puppetlabs-vcsrepo
# puppet module install puppetlabs-nodejs
# puppet module install stahnma-epel
# puppet module install puppetlabs-apache
# puppet module install dwerder/redis
class quest::setup {

# Client Configuration
  require epel
  require nodejs

  class { 'apache':
    default_vhost => false,
  }

  package { 'git':
    ensure => installed,
    before => Vcsrepo['/opt/browserquest'],
  }

  vcsrepo { '/opt/browserquest':
    ensure    => present,
    provider  => git,
    source    => 'https://github.com/ryanycoleman/BrowserQuest.git',
    notify    => Service['httpd'],
  }

  exec { '/usr/bin/npm install -d':
    cwd         => '/opt/browserquest',
    subscribe   => Vcsrepo['/opt/browserquest'],
    environment => 'HOME=/root'
  }

  exec { '/bin/bash build.sh':
    cwd       => '/opt/browserquest/bin',
    subscribe => Vcsrepo['/opt/browserquest'],
  }

  apache::vhost { 'browswerquest.app':
    port => 80,
    docroot => '/opt/browserquest/client-build',
    require => Exec['/bin/bash build.sh'],
  }


# Server Configuration
  include redis::install
  redis::server { 'redis': }

  package { 'forever':
    ensure   => installed,
    provider => npm,
    before   => Service['browserquest'],
  }

  file { '/etc/rc.d/init.d/browserquest':
    ensure  => file,
    mode    => 0755,
    source  => 'puppet:///modules/quest/browserquest_service',
    require => Vcsrepo['/opt/browserquest'],
  }

  service { 'browserquest':
    ensure  => running,
    require => File['/etc/rc.d/init.d/browserquest'],
  }

  service { 'iptables':
    ensure => stopped,
  }

}
