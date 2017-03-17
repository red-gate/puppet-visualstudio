# Encoding: utf-8
require_relative 'spec_windowshelper'

# Check for a list of installed package that suggest that the Build Tools install
# was successfull
[
  'Microsoft Visual Studio 2017',
  'Windows Software Development Kit - Windows 10.0.14393.795'
].each do |name|
  describe package(name) do
    it { should be_installed }
  end
end

[
  'C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/MSBuild/Microsoft/VisualStudio/v15.0/Web/Microsoft.Web.Publishing.targets',
  'C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/MSBuild/15.0/Bin/MSBuild.exe'
].each do |path|
  describe file(path) do
    it { should be_file }
  end
end

describe windows_registry_key('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment') do
  it { should have_property_value('BUILDTOOLS_VERSION', :type_string, "2017") }
end
