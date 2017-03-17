# Setup default values
class visualstudio::params {
  $temp_folder = 'c:/windows/temp'

  $buildtools2017_components = [
    'Microsoft.VisualStudio.Workload.MSBuildTools',
    'Microsoft.VisualStudio.Workload.WebBuildTools',
    'Microsoft.VisualStudio.Workload.VCTools',
    'Microsoft.VisualStudio.Component.VC.ATLMFC',
    'Microsoft.VisualStudio.Component.Windows10SDK.14393',
  ]

  $buildtools2017_installer_url = 'https://download.microsoft.com/download/5/A/8/5A8B8314-CA70-4225-9AF0-9E957C9771F7/vs_BuildTools.exe'

}
