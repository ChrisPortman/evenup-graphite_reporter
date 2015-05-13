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
# [*graphite_prefix*]
#   String.  Base prefix to be added to graphite metrics.
#   Default: undef
#
# [*use_fqdn_tree*]
#   Boolean.  Split the node fqdn by '.', reverse the parts and rejoin them with '.' to create a graphite metric tree from the domain.
#   Default: true
#
# [*append_puppet_to_prefix*]
#   Boolean. The prefix is comprised of 'graphite_prefix' and the node fqdn either as a single string or
#   as a tree depending on 'use_fqdn_tree'. If true, this option will add 'puppet' to the prefix.
#   Default: true
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
  $graphite_host           = $graphite_reporter::params::graphite_host,
  $graphite_port           = $graphite_reporter::params::graphite_port,
  $graphite_prefix         = $graphite_reporter::params::graphite_prefix,
  $use_fqdn_tree           = $graphite_reporter::params::use_fqdn_tree,
  $append_puppet_to_prefix = $graphite_reporter::params::append_puppet_to_prefix,
  $config_file             = $graphite_reporter::params::config_file,
  $config_owner            = $graphite_reporter::params::config_owner,
  $config_group            = $graphite_reporter::params::config_group,

) inherits graphite_reporter::params {

  validate_string($graphite_host, $config_file, $config_owner, $config_group)
  validate_bool($use_fqdn_tree, $append_puppet_to_prefix)

  file { $config_file:
    ensure  => file,
    owner   => $config_owner,
    group   => $config_group,
    mode    => '0444',
    content => template('graphite_reporter/graphite.yaml.erb'),
  }

}

