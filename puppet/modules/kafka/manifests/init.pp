class kafka {
  #
  # Puppet module for installing Apache Kafka.  This example uses the
  # Debian/Ubuntu package available in most distributions.  In
  # production environments you may need to download and unpack a
  # specific Kafka release and configure Zookeeper or KRaft mode.
  #
  package { 'kafka':
    ensure => installed,
  }

  service { 'kafka':
    ensure => running,
    enable => true,
    require => Package['kafka'],
  }
}