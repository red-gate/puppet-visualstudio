# Setup the Visual Studio Installer.
# We currently use the 'Enterprise' edition installer.
# (So VS Enterprise Core Editor is installed by default.)
# But we should still be able to install Comunity and Professional
# editions side by side.
define visualstudio::vsinstaller::installer(
  $channel_id,
  $edition = $title,
  $temp_folder = 'c:/windows/temp',
  $custom_install_path = undef
  ) {

  $year = $channel_id ? {
    'VisualStudio.15.Release'  => '2017',
    'VisualStudio.16.Release'  => '2019',
    default => fail("Unsupported value '${channel_id}' for the channel_id parameter.")
  }

  $installer_url = $channel_id ? {
    'VisualStudio.15.Release'  => 'https://download.microsoft.com/download/2/5/A/25A04A50-3CB3-495A-ACD0-1C8640A53CA7/vs_Enterprise.exe',
    'VisualStudio.16.Release'  => 'https://download.visualstudio.microsoft.com/download/pr/02aebac1-9464-4473-9af5-710a97b8f023/7f1ed0c7a0dd03d1e9dfc860a215dea84fe791cf0cd0b8cbe67e78c4cbd0c021/vs_Enterprise.exe',
    default => fail("Unsupported value '${channel_id}' for the channel_id parameter.")
  }

  require archive

  # Path where the VS installer bootstrapper will be downloaded.
  $installer = inline_template('<%= @temp_folder + "/" + File.basename(@installer_url, ".*") + "_" + @year + ".exe" %>')

  if !member(['Community', 'Professional', 'Enterprise', 'BuildTools'], $edition) {
    fail("Unsupported VS ${year} Edition: '${edition}'. Supported values are 'Community', 'Professional', 'Enterprise', 'BuildTools'")
  }
  $product_id = "Microsoft.VisualStudio.Product.${edition}"

  $install_path = $custom_install_path ? {
    undef   => "C:\\Program Files (x86)\\Microsoft Visual Studio\\${year}\\${edition}",
    default => $custom_install_path,
  }

  ensure_resource('archive', $installer, { source => $installer_url })

  exec { "VS ${year}: Install Core product ${product_id}":
    command   => "\$process = Start-Process -FilePath '${installer}' \
-ArgumentList '--installPath \"${install_path}\" --productId ${product_id} --channelId ${channel_id} --quiet --norestart' \
-Wait -PassThru; \
exit \$process.ExitCode",
    timeout   => 1200,
    onlyif    => "if( Resolve-Path C:/ProgramData/Microsoft/VisualStudio/Packages/_Instances/*/state.json | \
Get-Content -Raw | \
ConvertFrom-Json | \
where { \$_.product.id -eq '${product_id}' -and \$_.channelId -eq '${channel_id}' }) { exit 1 }",
    provider  => 'powershell',
    logoutput => true,
    require   => Archive[$installer],
  }

}
