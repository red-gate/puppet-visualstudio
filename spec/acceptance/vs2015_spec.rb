# Encoding: utf-8
require_relative 'spec_windowshelper'

# Check for a list of installed package that suggest that the VS install
# was successfull
[
  'Microsoft Visual Studio Professional 2015',
  'Microsoft .NET Framework 4.5.1 SDK',
  'Microsoft .NET Framework 4.6 SDK',
  'Microsoft .NET Framework 4.6.1 SDK',
  'Microsoft SQL Server 2014 Management Objects ',
  'Microsoft SQL Server 2016 Management Objects ',
  'Prerequisites for SSDT ',
  'Microsoft SQL Server Data Tools - enu (*)',
  'Microsoft Office Developer Tools for Visual Studio 2015',
  'Microsoft .NET Core 1.0.1 - VS 2015 Tooling Preview 2'
].each do |name|
  describe package(name) do
    it { should be_installed }
  end
end

describe file('C:/Program Files (x86)/MSBuild/Microsoft/VisualStudio/v14.0/Web/Microsoft.Web.Publishing.targets') do
  it { should be_file }
end
