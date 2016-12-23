# Encoding: utf-8
require_relative 'spec_windowshelper'

# Check for a list of installed package that suggest that the VS install
# was successfull
[
  'Microsoft Visual Studio Community 2015',
  'Microsoft .NET Framework 4.5.1 SDK',
  'Microsoft .NET Framework 4.6 SDK',
  'Microsoft .NET Framework 4.6.1 SDK',
  'Microsoft SQL Server 2014 Management Objects ',
  'Microsoft SQL Server 2016 Management Objects ',
  'Prerequisites for SSDT ',
  'Microsoft SQL Server Data Tools - enu (*)'
].each do |name|
  describe package(name) do
    it { should be_installed }
  end
end
