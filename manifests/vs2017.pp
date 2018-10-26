# Install and configure Visual Studio 2017
#
# $editions: An array of editions to install.
#   valid values are 'Community', 'Professional', 'Enterprise'.
#   default to ['Professional']
#
# $components: An array of ids of components/workloads to be installed.
#   default to ['Microsoft.VisualStudio.Workload.VisualStudioExtension', 'Microsoft.VisualStudio.Component.Web']
#
# $ssdtbi_version: The version of "SQL Server Data Tools - Visual Studio 2017" to install as displayed in "Program Features".
#                  Note that this will only work properly if only 1 instance/edition of VS 2017 is installed.
class visualstudio::vs2017(
  $editions = ['Professional'],
  $components = ['Microsoft.VisualStudio.Workload.VisualStudioExtension', 'Microsoft.VisualStudio.Component.Web'],
  $ssdtbi_version = undef,
  ) {

  if !$editions.is_a(Array) {
    fail('The editions parameter expects an array')
  }

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

  if $ssdtbi_version {
    $ssdtbi_urls = {
      '14.0.16179.0' => 'https://go.microsoft.com/fwlink/?linkid=2024393',
    }

    $url = $ssdtbi_urls[$ssdtbi_version]
    if $url == undef {
      fail("visualstudio::vs2017 does not know where to download SSDT BI v${ssdtbi_version}")
    }

    require archive
    archive { "C:/Windows/Temp/SSDT-Setup-ENU-${ssdtbi_version}.exe":
      source => $url,
    }
    -> package { 'Microsoft SQL Server Data Tools - Visual Studio 2017':
      ensure          => $ssdtbi_version,
      source          => "C:/Windows/Temp/SSDT-Setup-ENU-${ssdtbi_version}.exe",
      install_options => ['/quiet', '/norestart', '/INSTALLALL'],
      require         => Visualstudio::Vs2017::Installer[$editions],
    }

    Package['Microsoft SQL Server Data Tools - Visual Studio 2017'] -> Windows_env['VISUALSTUDIO_VERSION=2017']
  }
}
