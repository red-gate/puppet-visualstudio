# Encoding: utf-8
require_relative 'spec_windowshelper'

describe package('Microsoft Visual Studio Professional 2013 with Update 5') do
  it { should be_installed }
end
describe package('Microsoft Visual Studio 2013 SDK - ENU') do
  it { should be_installed }
end
describe package('Microsoft SQL Server Data Tools - Visual Studio 2013') do
  it { should be_installed }
end

describe windows_registry_key('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment') do
  it { should have_property_value('VISUALSTUDIO_VERSION', :type_string, "2013.5") }
  it { should have_property_value('SSDT_VERSION', :type_string, "VS2013") }
end
