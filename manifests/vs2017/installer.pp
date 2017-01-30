# Setup the Visual Studio 2017 Installer.
# We currently use the 'Enterprise' edition installer.
# (So VS 2017 Enterprise Core Editor is installed by default.)
# But we should still be able to install Comunity and Professional
# editions side by side.
define visualstudio::vs2017::installer(
  $installer_url = 'https://aka.ms/vs/15/release/vs_Enterprise.exe',
  $temp_folder = 'c:/windows/temp',
  $channel_id = 'VisualStudio.15.Release',
  $edition = $title,
  $custom_install_path = undef
  ) {

  require archive

  $vs_year = '2017'
  # Path where the VS installer bootstrapper will be downloaded.
  $installer = inline_template('<%= @temp_folder + File.basename(@installer_url, ".*") + "_" + @vs_year + ".exe" %>')

  if !member(['Community', 'Professional', 'Enterprise'], $edition) {
    fail("Unsupported VS ${vs_year} Edition: '${edition}'. Supported values are 'Community', 'Professional', 'Enterprise'")
  }
  $product_id = "Microsoft.VisualStudio.Product.${edition}"

  $install_path = $custom_install_path ? {
    undef   => "C:\\Program Files (x86)\\Microsoft Visual Studio\\${vs_year}\\${edition}",
    default => $custom_install_path,
  }

  ensure_resource('archive', $installer, { source => $installer_url })

  exec { "VS ${vs_year}: Install Core product ${product_id}":
    command   => "\$process = Start-Process -FilePath '${installer}' \
-ArgumentList '--installPath \"${install_path}\" --productId ${product_id} --channelId ${channel_id} --quiet --norestart' \
-Wait -PassThru; \
exit \$process.ExitCode",
    timeout   => 1200,
    # there must be a better way to detect installed products right? :sweat: :worried:
    onlyif    => "if( Resolve-Path C:/ProgramData/Microsoft/VisualStudio/Packages/_Instances/*/state.json | \
Get-Content -Raw | \
ConvertFrom-Json | \
where { \$_.product.id -eq '${product_id}' }) { exit 1 }",
    provider  => 'powershell',
    logoutput => true,
    require   => Archive[$installer],
  }

}
