# Install and configure VS 2015 Community eddition.
class visualstudio::vs2015_community(
  $installer_url = 'http://download.microsoft.com/download/0/B/C/0BC321A4-013F-479C-84E6-4A2F90B11269/vs_community.exe',
  $temp_folder = 'c:/windows/temp',
  # if true, do not let the VS installer grab the latest versions/updates of its components.
  $rtm = false,
  # ';' separated list of additional features passed to /InstallSelectableItems
  # 'SQL' will install the latest version of 'SQL Server Data Tools' (SSDT)
  $features = 'SQL'
  ) {
  require archive

  if $rtm {
    $allfeatures = "${features} /NoRefresh"
  } elsif empty($features) {
    # Get the installer to install the latest VS update only.
    $allfeatures = 'VSU;MicroUpdate'
  } else {
    # Get the installer to install the latest VS update + any feature passed in
    $allfeatures = "VSU;MicroUpdate;${features}"
  }

  $vs_install_command = "vs_community_2015.exe /NoRestart /Quiet /InstallSelectableItems ${allfeatures}"

  archive { "${temp_folder}/vs_community_2015.exe":
    source => $installer_url,
  }
  ->
  reboot { 'Reboot before installing/updating VS 2015 (if pending)':
    when => pending,
  }
  ->
  exec { 'Install Visual Studio 2015':
    command => $vs_install_command,
    path    => $temp_folder,
    # This DLL is a better indication of a successful install than devenv.exe, as the DLL is installed late in the installation
    creates => 'C:/Program Files (x86)/Microsoft Visual Studio 14.0/Common7/IDE/Microsoft.VisualStudio.Debugger.dll',
    timeout => 6000, # 100mins to install
    returns => [0, 3010],
  }
  ->
  reboot { 'Reboot after installing/updating VS 2015 (if pending)':
    when => pending,
  }

}
