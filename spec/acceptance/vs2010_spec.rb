# Encoding: utf-8
require_relative '../../../spec_windowshelper'

describe package('Microsoft Visual Studio 2010 Premium - ENU') do
  it { should be_installed}
end

describe windows_registry_key('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment') do
  it { should have_property_value('VISUALSTUDIO_VERSION', :type_string, "2010") }
end
