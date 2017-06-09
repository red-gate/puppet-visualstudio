# Install and configure VS 2015
class visualstudio::vs2015(
  $installer_url = 'http://go.microsoft.com/fwlink/?LinkID=786520&clcid=0x409',
  $temp_folder = 'c:/windows/temp',
  $install_vcplusplus = true
  ) {
  include archive

  $temp_folder_with_backslash = regsubst($temp_folder, '/', '\\', 'G')
  $vs_install_path = 'C:/Program Files (x86)/Microsoft Visual Studio 14.0'
  $vs_msbuild_install_path = 'C:/Program Files (x86)/MSBuild/Microsoft/VisualStudio/v14.0'
  $vs_install_command = 'vs_professional_2015.exe /norestart /quiet /InstallSelectableItems'

  reboot { 'Reboot before installing/updating VS 2015 (if pending)':
    when => pending,
  }

  Exec {
    timeout => 1200, # 20mins timeout for any command by default.
    path    => $temp_folder,
    require => Reboot['Reboot before installing/updating VS 2015 (if pending)'],
    notify  => Reboot['Reboot after installing/updating VS 2015 (if pending)'],
  }

  Package {
    require => Reboot['Reboot before installing/updating VS 2015 (if pending)'],
    notify  => Reboot['Reboot after installing/updating VS 2015 (if pending)'],
  }

  archive { "${temp_folder}/vs_professional_2015.exe":
    source => $installer_url,
  }
  ->
  exec { 'Install Visual Studio 2015':
    command => 'vs_professional_2015.exe /norestart /quiet',
    # This DLL is a better indication of a successful install than devenv.exe, as the DLL is installed late in the installation
    creates => "${vs_install_path}/Common7/IDE/Microsoft.VisualStudio.Debugger.dll",
    timeout => 6000, # 100mins to install
    returns => [0, 3010],
  }
  ->
  exec { 'Install Visual Studio 2015 SDK':
    command => "${vs_install_command} VS_SDK_GROUP;VS_SDK_Breadcrumb_Group",
    creates => "${vs_install_path}/VSSDK/",
    timeout => 2400, # 40mins to install
  }
  ->
  exec { 'Install Visual Studio 2015 SSDT':
    command => "${vs_install_command} SQL",
    creates => "${vs_msbuild_install_path}/SSDT/",
  }

  if $install_vcplusplus {

    exec { 'Install Visual Studio 2015 C++ tooling':
      command => "${vs_install_command} NativeLanguageSupport_VC",
      creates => "${vs_install_path}/VC/Bin/cl.exe",
      require => Exec['Install Visual Studio 2015 SSDT'],
    }
    ->
    exec { 'Install Visual Studio 2015 MFC classes for C++':
      command => "${vs_install_command} NativeLanguageSupport_MFC",
      creates => "${vs_install_path}/VC/atlmfc/src/mfc/",
    }
    # ->
    # # If we needed to target win xp from VS 2015
    # exec { 'Install Visual Studio 2015 XP Support for C++':
    #   command => "${install_command} NativeLanguageSupport_XP",
    #   creates => "${vs_install_path}/??TODO??",
    # }

    $final_vs_task = Exec['Install Visual Studio 2015 MFC classes for C++']
  } else {
    $final_vs_task = Exec['Install Visual Studio 2015 SSDT']
  }

  # Install Office Tools separately to keep things small. (used by a couple of internal builds for outlook addins.)
  archive { "${temp_folder}/OfficeToolsForVS2015_cba_bundle.exe":
    source => 'http://go.microsoft.com/fwlink/?LinkID=780545&clcid=0x409'
  }
  ->
  package { 'Microsoft Office Developer Tools for Visual Studio 2015':
    source          => "${temp_folder}/OfficeToolsForVS2015_cba_bundle.exe",
    install_options => ['/quiet', '/norestart'],
    require         => [Exec['Install Visual Studio 2015'], Reboot['Reboot before installing/updating VS 2015 (if pending)']],
  }

  archive { "${temp_folder}/WebToolsExtensionsVS14.msi":
    source => 'https://download.microsoft.com/download/3/C/A/3CAA9F6A-1856-43D3-922D-416D187A6929/WebToolsExtensionsVS14.msi'
  }
  ->
  # install 'Microsoft ASP.NET and Web Tools 2015.1 RC - Visual Studio 2015' in order to get
  # C:/Program Files (x86)/MSBuild/Microsoft/VisualStudio/v14.0/Web/
  # Note that the .NET Core Tools will then upgrade this to RTM hence why we don't use a package resource.
  exec { 'Install Microsoft ASP.NET and Web Tools 2015.1 - Visual Studio 2015':
    command => "C:\\Windows\\System32\\msiexec.exe /package \"${temp_folder_with_backslash}\\WebToolsExtensionsVS14.msi\" /quiet /norestart",
    require => Exec['Install Visual Studio 2015'],
    creates => 'C:/Program Files (x86)/MSBuild/Microsoft/VisualStudio/v14.0/Web/Microsoft.Web.Publishing.targets',
  }

  # Intall Visual Studio 2015 .NET Core Tools (Preview 2)
  archive { "${temp_folder}/DotNetCore.1.0.1-VS2015Tools.Preview2.0.3.exe":
    source => 'https://download.microsoft.com/download/F/6/E/F6ECBBCC-B02F-424E-8E03-D47E9FA631B7/DotNetCore.1.0.1-VS2015Tools.Preview2.0.3.exe',
  }
  ->
  package { 'Microsoft .NET Core 1.0.1 - VS 2015 Tooling Preview 2':
    source          => "${temp_folder}/DotNetCore.1.0.1-VS2015Tools.Preview2.0.3.exe",
    install_options => ['/quiet', '/norestart'],
    require         => Exec['Install Microsoft ASP.NET and Web Tools 2015.1 - Visual Studio 2015'],
  }

  windows_env { 'VISUALSTUDIO_VERSION=2015':
    require => [
      $final_vs_task,
      Package['Microsoft Office Developer Tools for Visual Studio 2015'],
      Package['Microsoft .NET Core 1.0.1 - VS 2015 Tooling Preview 2'],
      ],
  }

  reboot { 'Reboot after installing/updating VS 2015 (if pending)':
    when => pending,
  }

  windows_env { 'VISUALSTUDIO_VERSION=2015.0':
    ensure => absent,
  }
}
