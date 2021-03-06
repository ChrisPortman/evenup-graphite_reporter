# == Class: graphite_reporter
#
# This class deploys and configures a puppet reporter to send reports to graphite
#
#
# === Parameters
#
# [*graphite_host*]
#   String.  Graphite host to write stats to
#   Default: 127.0.0.1
#
# [*graphite_port*]
#   Integer.  Port graphite is listening for tcp connections on
#   Default: 2003
#
# [*config_file*]
#   String.  Path to write the config file to
#   Default: /etc/puppet/graphite.yaml
#
# [*config_owner*]
#   String.  Owner of the config file. Should be pe_puppet for Puppet Enterprise.
#   Default: puppet
#
# [*config_group*]
#   String.  The config file's group. Should be pe_puppet for Puppet Enterprise.
#   Default: puppet
#
#
# === Examples
#
# * Installation:
#     class { 'graphite_reporter':
#       graphite_host => 'graphite.mycompany.com',
#     }
#
#
# === Authors
#
# * Naresh V. <mailto:nareshov@gmail.com>
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
#
class graphite_reporter (
  $graphite_host  = $graphite_reporter::params::graphite_host,
  $graphite_port  = $graphite_reporter::params::graphite_port,
  $config_file    = $graphite_reporter::params::config_file,
  $config_owner   = $graphite_reporter::params::config_owner,
  $config_group   = $graphite_reporter::params::config_group,
) inherits graphite_reporter::params {

  file { $config_file:
    ensure  => file,
    owner   => $config_owner,
    group   => $config_group,
    mode    => '0444',
    content => template('graphite_reporter/graphite.yaml.erb'),
  }

}

