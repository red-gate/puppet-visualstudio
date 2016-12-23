# Install a given VS 2017 Component/Workload
define visualstudio::vs2017::component(
  $edition = undef,
  $id = undef,
  $channel_id = 'VisualStudio.15.Release'
  ) {

  if $edition == undef or $id == undef {
    # Let's parse the edition and component id from the resource title.
    # If the parameters were not used.
    # expected format: '<edition>:<component_id>'

    if $title =~ /(.+):(.+)/ {
      $internal_edition = $1
      $internal_id = $2
    } else {
      fail("edition and/or id are missing and cannot be parsed from resource title: ${title}. \
Either format your resource name/title as '<edition>:<component_id>' or use the edition and id parameters.")
    }
  } else {
    $internal_edition = $edition
    $internal_id = $id
  }

  if !member(['Community', 'Professional', 'Enterprise'], $internal_edition) {
    fail("Unsupported VS 2017 Edition: '${internal_edition}'. Supported values are 'Community', 'Professional', 'Enterprise'")
  }
  $product_id = "Microsoft.VisualStudio.Product.${internal_edition}"

  $vs_installer_path = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installershell.exe'

  exec { "VS 2017: Install component/workload ${internal_id} to ${internal_edition} edition.":
    command   => "\$process = Start-Process -FilePath '${vs_installer_path}' \
-ArgumentList 'modify --productId ${product_id} --channelId ${channel_id} --add ${internal_id} --quiet --norestart' \
-Wait -PassThru; \
exit \$process.ExitCode",
    timeout   => 1200,
    # there must be a better way to detect installed components/workloads right? :sweat: :worried:
    onlyif    => "if( Resolve-Path C:/ProgramData/Microsoft/VisualStudio/Packages/_Instances/*/state.json | \
Get-Content -Raw | \
ConvertFrom-Json | \
where { \$_.product.id -eq '${product_id}' } | \
select -ExpandProperty selectedPackages | \
where { \$_.id -eq '${internal_id}' -and ('GroupSelected', 'IndividuallySelected') -contains \$_.selectedState }) { exit 1 }",
    provider  => 'powershell',
    logoutput => true,
  }

}
