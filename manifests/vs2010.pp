# Install Visual Studio 2010 SP1.
class visualstudio::vs2010 {
  require windows_sdks::win7
  include archive

  file { 'c:/temp/vs2010':
    ensure  => directory,
    require => File['c:/temp'],
  }
  ->
  archive { 'c:/temp/vs2010/vs_premiumweb.exe':
    source => 'http://download.microsoft.com/download/B/1/7/B17C731C-3161-45C0-AC16-56C81BAAF85C/vs_premiumweb.exe',
  }
  ->
  file { 'c:/temp/vs2010/custom.ini':
  ensure             => 'file',
  source             => 'puppet:///modules/visualstudio/vs2010-custom.ini',
  source_permissions => ignore,
  }
  ->
  package { 'Microsoft Visual Studio 2010 Premium - ENU' :
    source          => 'c:/temp/vs2010/vs_premiumweb.exe',
    install_options => ['/unattendfile c:\temp\vs2010\custom.ini', '/quiet', '/norestart'],
    require         => [Package['Microsoft Windows SDK for Windows 7 (7.1)']],
  }
  ->
  exec { 'c:/temp/vs2010/VS10sp1-KB983509.exe':
    command  => 'Invoke-WebRequest "http://download.microsoft.com/download/2/3/0/230C4F4A-2D3C-4D3B-B991-2A9133904E35/VS10sp1-KB983509.exe" -OutFile "c:/temp/vs2010/VS10sp1-KB983509.exe"',
    provider => powershell,
    creates  => 'c:/temp/vs2010/VS10sp1-KB983509.exe',
  }
  ->
  package { 'Microsoft Visual Studio 2010 Service Pack 1' :
    source          => 'c:/temp/vs2010/VS10sp1-KB983509.exe',
    install_options => ['/norestart', '/q'],
  }
  ->
  file { 'c:/temp/vs2010/vs2010sdksp1':
    ensure  => directory,
  }
  ->
  archive { 'c:/temp/vs2010/vs2010sdksp1_sfx.exe':
    source       => 'https://download.microsoft.com/download/C/F/D/CFD1CDDA-3046-4D13-8A6C-793EBAFDECFE/VsSDK_sfx.exe',
    extract      => true,
    extract_path => 'c:/temp/vs2010/vs2010sdksp1',
    creates      => 'c:/temp/vs2010/vs2010sdksp1/vssdk.msi',
    cleanup      => true,
  }
  ->
  package { 'Microsoft Visual Studio 2010 SDK SP1' :
      source          => 'c:/temp/vs2010/vs2010sdksp1/vssdk.msi',
      install_options => ['/qb'],
  }
  ->
  windows_env { 'VISUALSTUDIO_VERSION=2010': }
  # TODO: Workaround 1 from http://blogs.msdn.com/b/vcblog/archive/2011/03/11/10140139.aspx
  # This has never been implemented properly and we do not seem to be suffering from it,
  # hold off for now. [Nico - Nov 2015]
}
