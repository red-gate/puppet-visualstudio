# Install the Microsoft Visual C++ Express 2008 SP1
#
# $atlmfcSourceUrl: The url to atlmfc.7z which is a zip file containing files taken from a VS2008 install in C:/Program Files (x86)/Microsoft Visual Studio 9.0/VC
#
# $tempFolder: The folder where the installer will be downloaded to and the install started from.
class visualstudio::visualcplusplus2008(
  $atlmfcSourceUrl,
  $tempFolder = 'c:/temp') {

    include archive

    if (!defined(File[$tempFolder]))
    {
      file { $tempFolder:
        ensure   => directory,
      }
    }

    file { "${tempFolder}/CPlusPlusExpress2008":
      ensure  => directory,
      require => File[$tempFolder],
    }
    ->
    # Download and extract the Visual C++ Express 2008 installer
    archive { "${tempFolder}/CPlusPlusExpress2008.exe":
      # We do need to extract this file as there is no way to use it silently. :rage:
      # Instead, extract and use the inner Setup.exe file which does support silent arguments.
      extract       => true,
      extract_path  => "${tempFolder}/CPlusPlusExpress2008",
      source        => 'http://go.microsoft.com/?linkid=7729279',
      creates       => "${tempFolder}/CPlusPlusExpress2008/Setup.exe",
      cleanup       => true,
      # Need extra flags to let 7zip know this is "some-kind-of cab file" ?
      # Without this, the latest version of 7zip doesn't give us a Setup.exe...
      extract_flags => 'x -aoa -tCAB',
    }
    ->
    # Silent web install
    package { 'Microsoft Visual C++ 2008 Express Edition with SP1 - ENU' :
      ensure          => installed,
      source          => "${tempFolder}/CPlusPlusExpress2008/Setup.exe",
      install_options => ['/qb', '/norestart', '/web', '/log', "${tempFolder}\\CPlusPlusExpress2008\\setup.log.txt"],
    }
    ->
    file { 'C:/Program Files (x86)/Microsoft Visual Studio 9.0/VC/atlmfc':
      ensure  => directory,
    }
    ->
    # Get atlmfc files needed to compile some of our tools (e.g. the Red Gate Installer.)
    archive { "${tempFolder}/VS2008_atlmfc.7z":
      extract      => true,
      extract_path => 'C:/Program Files (x86)/Microsoft Visual Studio 9.0/VC/atlmfc',
      source       => $atlmfcSourceUrl,
      creates      => 'C:/Program Files (x86)/Microsoft Visual Studio 9.0/VC/atlmfc/include/afxwin.h',
      cleanup      => true,
    }
    ->
    # Need to register VCProjectEngine.dll to fix 'warning MSB3422: Failed to retrieve VC project information through the VC project engine object model'
    # http://blogs.msdn.com/b/jjameson/archive/2009/11/07/compiling-c-projects-with-team-foundation-build.aspx
    exec { 'register C:/Program Files (x86)/Microsoft Visual Studio 9.0/VC/vcpackages/VCProjectEngine.dll' :
      path    => 'C:/Windows/System32',
      command => 'regsvr32 "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcpackages\VCProjectEngine.dll" /s',
      creates => 'C:/Program Files (x86)/Microsoft Visual Studio 9.0/VC/vcpackages/VCProjectEngine.dll.flag',
    }
    ->
    file { 'C:/Program Files (x86)/Microsoft Visual Studio 9.0/VC/vcpackages/VCProjectEngine.dll.flag':
      ensure => present,
    }
    ->
    windows_env { 'VISUALSTUDIO_VERSION=C++Express2008SP1': }
}
