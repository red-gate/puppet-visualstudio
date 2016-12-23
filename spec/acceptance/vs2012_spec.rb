# Encoding: utf-8
require_relative 'spec_windowshelper'

describe package('Microsoft Visual Studio Premium 2012') do
  it { should be_installed}
end
describe package('Microsoft Visual Studio 2012 SDK - ENU') do
  it { should be_installed}
end

describe windows_registry_key('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment') do
  it { should have_property_value('VISUALSTUDIO_VERSION', :type_string, "2012.0") }
  it { should have_property_value('SSDT_VERSION', :type_string, "11.0.5583.0") }
end
