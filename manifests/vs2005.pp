# Install Microsoft Visual Studio 2005 Standard
#
#
# $tempFolder: The folder where the installer will be downloaded to and the install started from.
#
class visualstudio::vs2005(
  $isourl,
  $tempFolder = 'c:/temp') {

    require ::archive
    ensure_resource('file', $tempFolder, { ensure => directory })

    $vsfolder = "${tempFolder}/VS2005"
    $isofilename = inline_template('<%= File.basename(@isourl) %>')

    reboot { 'reboot before installing VS 2005 (if pending)':
      when => pending,
    }

    file { $vsfolder:
      ensure  => directory,
      require => File[$tempFolder],
    }
    ->
    # Download and extract the Visual Studio 2005 iso image.
    archive { "${tempFolder}/${isofilename}":
      ensure       => present,
      extract      => true,
      extract_path => $vsfolder,
      source       => $isourl,
      creates      => "${$vsfolder}/vs/Setup/setup.exe",
      cleanup      => true,
    }
    ->
    # Install some prerequisites ourselves to work around the installer crashing
    package { 'Microsoft Visual Studio 2005 64bit Prerequisites (x64) - ENU' :
      ensure          => installed,
      source          => "${vsfolder}/vs/wcu/64bitPrereq/x64/vs_bsln.exe",
      install_options => ['/Q'],
    }
    ->
    # Install VS 2005.
    # Reverse engineered the way setup.exe works, as it seems to be failing to install some prerequisites.
    # We only use VS2005 for a single build, so this will have to do.
    package { 'Microsoft Visual Studio 2005 Team Edition for Software Developers - ENU' :
      ensure          => installed,
      source          => "${vsfolder}/vs/vs_setup.msi",
      install_options => [
        'VSEXTUI=1',
        'SETUPWINDOW=0',
        'INSTALLLEVEL=2',
        'USERNAME=Puppet',
        'REBOOT=ReallySuppress',
        'PIDKEY=BW7KFJ86TJBW47MF2WPD2QT6D',
        'COMPANYNAME=Redgate',
        'ALLUSERS=1',
        'REINSTALLMODE=omus',
        'ADDLOCAL=Visual_Studio_Ent_Dev,Language_Tools_for_VS_7_Ent,VB_for_VS_7_Ent,VCpp_for_VS_7_Ent,VCpp_Class_and_Template_Libraries,ATL_MFC_Static_Libraries_ANSI,ATL_MFC_Shared_Libraries_ANSI,ATL_MFC_Static_Libraries_Unicode,ATL_MFC_Shared_Libraries_Unicode,ATL_MFC_Source_Code,VCpp_Tools,Trace_Utility,ActiveX_Control_Test_Container,Error_Lookup,Platform_SDK_Tools,x64_Compilers_and_Tools,Itanium_Compilers_and_Tools,VCpp_Runtime_Libraries_Pro,CRT2_Static_Libraries,CRT3_Shared_Libraries,CRT4_Source_Code,VCsh_for_VS_7_Ent,VS_Remote_Debugging,dotNET_Framework_SDK,SDK_Tools,TSDevPkg,Crystal_Reports_IA64_Modules,ProductRegKeyVSTD,ARP_REG_KEYS_HIDDEN_VS_VSTD_ENU_X86,Servicing_Key'
      ],
      require         => Reboot['reboot before installing VS 2005 (if pending)'],
    }
    ->
    archive { "${$vsfolder}/VS80sp1-KB926601-X86-ENU.exe":
      ensure => present,
      source => 'https://download.microsoft.com/download/6/3/c/63c69e5d-74c9-48ea-b905-30ac3831f288/VS80sp1-KB926601-X86-ENU.exe',
    }
    ->
    # Install VS2005 SP1
    exec { 'Install Microsoft Visual Studio 2005 Standard Edition - ENU Service Pack 1 (KB926748)' :
      path     => $vsfolder,
      command  => 'VS80sp1-KB926601-X86-ENU.exe /quiet',
      onlyif   => 'if( Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Active Setup\Installed Components\{D93F9C7C-AB57-44C8-BAD6-1494674BCAF7}\" ) { exit 1 }',
      provider => powershell,
    }
    ->
    package { 'vcredist2005':
      ensure   => '8.1.0.20160118',
      provider => 'chocolatey'
    }
    ->
    windows_env { 'VISUALSTUDIO_VERSION=2005': }
}
