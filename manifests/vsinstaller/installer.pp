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
    'VisualStudio.15.Release'  => 'https://download.visualstudio.microsoft.com/download/pr/8807d71a-11f0-4c53-85c1-3f884f4ab74c/12fc37a0053330ccecf1d681fdbff22784d14cfb2dd04a9cf1973f4fec934795/vs_Enterprise.exe',
    'VisualStudio.16.Release'  => 'https://download.visualstudio.microsoft.com/download/pr/5a50b8ac-2c22-47f1-ba60-70d4257a78fa/c7d0579710fb4c3d9967e8e6d616610f051f0bbc408fd12ef48e45eeeaeab52b/vs_Enterprise.exe',
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
