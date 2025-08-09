node default {
  # Include classes to install and configure each component.  Comment out
  # any classes you don't need on a particular host.
  include kafka
  include rdbms
  include elasticsearch
  include spark
}