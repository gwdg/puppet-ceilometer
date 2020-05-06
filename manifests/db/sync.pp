# == Class: ceilometer::db::sync
#
# Class to execute ceilometer database schema creation
#
# === Parameters:
#
# [*extra_params*]
#   (Optional) String of extra command line parameters
#   to append to the ceilometer-upgrade command.
#   Defaults to '--skip-gnocchi-resource-types'.
#
class ceilometer::db::sync(
  $extra_params = '--skip-gnocchi-resource-types',
) {

  include ::ceilometer::params

  Package<| tag == 'ceilometer-package' |> ~> Exec['ceilometer-dbsync']
  Exec['ceilometer-dbsync'] ~> Service <| tag == 'ceilometer-service' |>

  Ceilometer_config<||> -> Exec['ceilometer-dbsync']
  Ceilometer_config<| title == 'database/connection' |> ~> Exec['ceilometer-dbsync']

  exec { 'ceilometer-dbsync':
    command     => "${::ceilometer::params::dbsync_command} ${extra_params}",
    path        => '/usr/bin',
    user        => $::ceilometer::params::user,
    refreshonly => true,
    try_sleep   => 5,
    tries       => 10,
    logoutput   => on_failure,
  }

}
