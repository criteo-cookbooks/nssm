# frozen_string_literal: true

require 'spec_helper'

describe 'nssm::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(file_cache_path: CACHE, platform: 'windows', version: '2008R2') do |node|
      node.override['nssm']['install_location'] = 'c:\somewhere'
    end.converge(described_recipe)
  end

  it 'copies nssm executable' do
    expect(chef_run).to_not run_batch('install nssm').with(
      code: %r{xcopy ".*\\nssm-.*\\win64\\nssm.exe" "c:\\somewhere" /y}
    )
  end
end
