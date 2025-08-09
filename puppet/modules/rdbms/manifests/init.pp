class rdbms {
  #
  # Puppet module for installing a relational database.  This example
  # installs PostgreSQL.  For MySQL or other engines modify the
  # package and service names accordingly.
  #
  package { 'postgresql':
    ensure => installed,
  }

  service { 'postgresql':
    ensure => running,
    enable => true,
    require => Package['postgresql'],
  }
}