# Install Visual Studio 2013
# Install Visual Studio 2013 SDK
# Install SSDT for Visual Studio 2013
class visualstudio::vs2013 {
  include archive

  ensure_resource('file', 'c:/temp', { ensure => directory })

  file { 'c:/temp/vs2013':
    ensure  => directory,
    require => File['c:/temp'],
  }
  ->
  file {'c:/temp/vs2013/admindeployment.xml':
    ensure             => 'file',
    source             => 'puppet:///modules/visualstudio/vs2013-admindeployment.xml',
    source_permissions => ignore,
  }
  ->
  archive { 'c:/temp/vs2013/en_visual_studio_professional_2013_with_update_5_x86_web_installer_6815765.exe':
    source  => 'https://download.microsoft.com/download/F/2/E/F2EFF589-F7D7-478E-B3AB-15F412DA7DEB/vs_professional.exe',
    require => File['c:/temp'],
  }
  ->
  package { 'Microsoft Visual Studio Professional 2013 with Update 5' :
    source          => 'C:/temp/vs2013/en_visual_studio_professional_2013_with_update_5_x86_web_installer_6815765.exe',
    install_options => ['/adminfile', 'c:\\temp\\vs2013\\admindeployment.xml', '/quiet',  '/norestart'],
  }
  ->
  windows_env { 'VISUALSTUDIO_VERSION=2013.5': }
  ->
  archive { 'c:/temp/vs2013/vssdk_full.exe':
    source  => 'https://download.microsoft.com/download/9/1/0/910EE61D-A231-4DAB-BD56-DCE7092687D5/vssdk_full.exe',
  }
  ->
  package { 'Microsoft Visual Studio 2013 SDK - ENU' :
    source          => 'c:/temp/vs2013/vssdk_full.exe',
    install_options => ['/Quiet', '/Full', '/NoRestart'],
  }
  ->
  archive { 'c:/temp/vs2013/SSDTSetup-VS2013.exe':
    source => 'https://download.microsoft.com/download/6/3/3/633CBD0D-12BE-4124-927C-47186017A000/Dev12/EN/SSDTSetup.exe',
  }
  ->
  package { 'Microsoft SQL Server Data Tools - Visual Studio 2013' :
    source          => 'c:/temp/vs2013/SSDTSetup-VS2013.exe',
    install_options => ['/q', '/NoRestart'],
  }
  ->
  windows_env { 'SSDT_VERSION=VS2013': }
}
