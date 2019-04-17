# Install and configure Visual Studio 2017
#
# $editions: An array of editions to install.
#   valid values are 'Community', 'Professional', 'Enterprise'.
#   default to ['Professional']
#
# $components: An array of ids of components/workloads to be installed.
#   default to ['Microsoft.VisualStudio.Workload.VisualStudioExtension', 'Microsoft.VisualStudio.Component.Web']
#
class visualstudio::vs2017(
  $editions = ['Professional'],
  $components = ['Microsoft.VisualStudio.Workload.VisualStudioExtension', 'Microsoft.VisualStudio.Component.Web']
  ) {
  
  if !$editions.is_a(Array) {
    fail('The editions parameter expects an array')
  }

  $editions.each |String $edition| {
    # Install VS Core editor for the given edition.
    visualstudio::vsinstaller::installer { $edition:
      channel_id => 'VisualStudio.15.Release',
    }

    # Install each component to that edition.
    $components.each |String $component| {
      visualstudio::vsinstaller::component { "${edition}:${component}":
        channel_id => 'VisualStudio.15.Release',
        require    => Visualstudio::Vsinstaller::Installer[$edition]
      }
    }
  }

  windows_env { 'VISUALSTUDIO_VERSION=2017': }

  # Only set the environment variable when all the VS components have
  # been successfully installed.
  Visualstudio::Vsinstaller::Component <| |> -> Windows_env['VISUALSTUDIO_VERSION=2017']
}
