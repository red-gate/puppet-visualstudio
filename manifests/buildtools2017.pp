# Install and configure Microsoft Build Tools 2017
#
# $components: An array of ids of components/workloads to be installed.
#
class visualstudio::buildtools2017(
  $installer_url = $visualstudio::params::buildtools2017_installer_url,
  $temp_folder   = $visualstudio::params::temp_folder,
  $components    = $visualstudio::params::buildtools2017_components
  ) inherits visualstudio::params {

  visualstudio::vs2017::installer { 'BuildTools':
    installer_url => $installer_url,
    temp_folder   => $temp_folder,
  }

  # Install each component to that edition.
  $components.each |String $component| {
    visualstudio::vs2017::component { "BuildTools:${component}":
      require => Visualstudio::Vs2017::Installer['BuildTools'],
    }
  }

  windows_env { 'BUILDTOOLS_VERSION=2017': }

  # Only set the environment variable when all the VS components have
  # been successfully installed.
  Visualstudio::Vs2017::Component <| |> -> Windows_env['BUILDTOOLS_VERSION=2017']
}
