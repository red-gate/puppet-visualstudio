# Install VS 2012 Premium
class visualstudio::vs2012 {
  include archive

  ensure_resource('file', 'c:/temp', { ensure => directory })

  file { 'c:/temp/vs2012':
    ensure  => directory,
    require => File['c:/temp'],
  }
  ->
  file {'c:/temp/vs2012/admindeployment.xml':
    ensure             => 'file',
    source             => 'puppet:///modules/visualstudio/vs2012-admindeployment.xml',
    source_permissions => ignore,
  }
  ->
  archive { 'c:/temp/vs2012/vs_premium.exe':
    source  => 'https://download.microsoft.com/download/1/3/1/131D8A8C-95D8-41D4-892A-1DF6E3C5DF7D/vs_premium.exe',
  }
  ->
  package { 'Microsoft Visual Studio Premium 2012':
    source          => 'c:/temp/vs2012/vs_premium.exe',
    install_options => ['/adminfile', 'c:\\temp\\vs2012\\admindeployment.xml', '/quiet',  '/norestart'],
  }
  ->
  archive { 'c:/temp/vs2012/vssdk_full.exe':
    source => 'https://download.microsoft.com/download/8/3/8/8387A8E1-E422-4DD5-B586-F1F2EC778817/vssdk_full.exe'
  }
  ->
  package { 'Microsoft Visual Studio 2012 SDK - ENU' :
    source          => 'c:/temp/vs2012/vssdk_full.exe',
    install_options => ['/Quiet', '/Full', '/NoRestart'],
  }
  ->
  windows_env { 'VISUALSTUDIO_VERSION=2012.0': }
  ->
  archive { 'c:/temp/vs2012/SSDT_VS2012.exe':
    source => 'http://go.microsoft.com/fwlink/?LinkID=617314',
  }
  ->
  package { 'Microsoft SQL Server Data Tools 2012':
    source          => 'c:/temp/vs2012/SSDT_VS2012.exe',
    install_options => ['/QUIET', '/IACCEPTSQLSERVERLICENSETERMS', '/ACTION=install'],
  }
  ->
  windows_env { 'SSDT_VERSION=11.0.5583.0': }
}
