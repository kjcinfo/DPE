class spark {
  # Simple Puppet manifest to install and start Apache Spark on a host.
  # This example assumes that Spark is available as a package on your
  # distribution.  In reality you may need to download a tarball,
  # extract it and manage systemd unit files.  Adapt as needed.

  case $facts['os']['family'] {
    'Debian': {
      package { 'spark':
        ensure => installed,
      }
    }
    'RedHat': {
      package { 'spark':
        ensure => installed,
      }
    }
    default: {
      warning('Spark package installation is not defined for this OS family')
    }
  }

  # Service resources are placeholders; adjust names to match your
  # distribution.  On many systems Spark is not managed via systemd by
  # default and you may need to manage the master and worker scripts.
  service { 'spark-master':
    ensure => running,
    enable => true,
    require => Package['spark'],
  }

  service { 'spark-worker':
    ensure => running,
    enable => true,
    require => Package['spark'],
  }
}