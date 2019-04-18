# Encoding: utf-8
require_relative 'spec_windowshelper'

# Check for a list of installed package that suggest that the VS install
# was successfull
[
  'Visual Studio Community 2019*',
  'Visual Studio Professional 2019*'
].each do |name|
  describe package(name) do
    it { should be_installed }
  end
end

describe file('C:/Program Files (x86)/Microsoft Visual Studio/2019/Professional/MSBuild/Microsoft/VisualStudio/v16.0/Web/Microsoft.Web.Publishing.targets') do
  it { should be_file }
end

describe file('C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/MSBuild/Microsoft/VisualStudio/v16.0/Web/Microsoft.Web.Publishing.targets') do
  it { should be_file }
end
