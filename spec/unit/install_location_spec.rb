require 'spec_helper'

describe 'nssm::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'windows', version: '2008R2') do |node|
      node.set['nssm']['install_location'] = 'c:\somewhere'
    end.converge(described_recipe)
  end

  it 'copies nssm executable' do
    expect(chef_run).to run_batch('copy_nssm').with(
      code: /xcopy .*\\nssm-2.24\\win64\\nssm.exe "c:\\somewhere" \/y/)
  end
end
