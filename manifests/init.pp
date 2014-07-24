class quest {

  vcsrepo { '/opt/browserquest':
    ensure    => present,
    provider  => git,
    source    => 'https://github.com/ryanycoleman/BrowserQuest.git',
    notify    => Service['browserquest'],
  }

  service { 'browserquest':
    ensure  => running,
  }

}
