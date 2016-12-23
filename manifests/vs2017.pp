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

  $editions.each |String $edition| {
    # Install VS Core editor for the given edition.
    visualstudio::vs2017::installer { $edition: }

    # Install each component to that edition.
    $components.each |String $component| {
      visualstudio::vs2017::component { "${edition}:${component}":
        require => Visualstudio::Vs2017::Installer[$edition]
      }
    }
  }

  windows_env { 'VISUALSTUDIO_VERSION=2017': }

  # Only set the environment variable when all the VS components have
  # been successfully installed.
  Visualstudio::Vs2017::Component <| |> -> Windows_env['VISUALSTUDIO_VERSION=2017']
}
