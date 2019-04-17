# Install and configure Visual Studio 2019
#
# $editions: An array of editions to install.
#   valid values are 'Community', 'Professional', 'Enterprise'.
#   default to ['Professional']
#
# $components: An array of ids of components/workloads to be installed.
#   default to ['Microsoft.VisualStudio.Workload.VisualStudioExtension', 'Microsoft.VisualStudio.Component.Web']
#
class visualstudio::vs2019(
  $editions = ['Professional'],
  $components = ['Microsoft.VisualStudio.Workload.VisualStudioExtension', 'Microsoft.VisualStudio.Component.Web']
  ) {

  if !$editions.is_a(Array) {
    fail('The editions parameter expects an array')
  }

  $editions.each |String $edition| {
    # Install VS Core editor for the given edition.
    visualstudio::vs2017::installer { $edition:
      year          => '2019',
      installer_url => 'https://download.visualstudio.microsoft.com/download/pr/99e5fb29-6ac9-4f66-8881-56b4d0a413b5/6d157d5ffdd201fb1d59ef8e29a9ce3b/vs_enterprise.exe',
      channel_id    => 'VisualStudio.16.Release',
    }

    # # Install each component to that edition.
    # $components.each |String $component| {
    #   visualstudio::vs2017::component { "${edition}:${component}":
    #     require => Visualstudio::Vs2017::Installer[$edition]
    #   }
    # }
  }

  windows_env { 'VISUALSTUDIO_VERSION=2019': }

  # Only set the environment variable when all the VS components have
  # been successfully installed.
  Visualstudio::Vs2017::Component <| |> -> Windows_env['VISUALSTUDIO_VERSION=2019']
}
