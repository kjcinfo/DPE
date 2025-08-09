class elasticsearch {
  #
  # Puppet module for installing Elasticsearch.  This example uses
  # the official package repository for Elasticsearch 8.x on Debian/Ubuntu.
  # The repository setup is simplified for demonstration purposes.
  #
  exec { 'add_elasticsearch_gpg_key':
    command => '/usr/bin/wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | /usr/bin/apt-key add -',
    unless  => '/usr/bin/apt-key list | /bin/grep -q "Elastic Release Key"',
    path    => ['/bin','/usr/bin'],
  }

  file { '/etc/apt/sources.list.d/elastic-8.x.list':
    ensure  => file,
    content => "deb https://artifacts.elastic.co/packages/8.x/apt stable main\n",
    notify  => Exec['apt_update'],
  }

  exec { 'apt_update':
    command => '/usr/bin/apt-get update',
    refreshonly => true,
    path => ['/bin','/usr/bin'],
  }

  package { 'elasticsearch':
    ensure  => installed,
    require => [Exec['apt_update'], Exec['add_elasticsearch_gpg_key']],
  }

  service { 'elasticsearch':
    ensure => running,
    enable => true,
    require => Package['elasticsearch'],
  }
}