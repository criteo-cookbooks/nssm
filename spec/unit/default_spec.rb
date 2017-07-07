# frozen_string_literal: true

require 'spec_helper'

describe 'nssm::default' do
  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        file_cache_path: CACHE, platform: 'windows', version: '2008R2'
      ).converge(described_recipe)
    end

    it 'download nssm' do
      expect(chef_run).to unzip_windows_zipfile('download nssm').with(
        path: "#{CACHE}/nssm-#{VERSION}.zip",
        source: "https://nssm.cc/release/nssm-#{VERSION}.zip"
      )
    end

    it 'install nssm' do
      expect(chef_run).to_not run_batch('install nssm').with(
        code: %r{xcopy ".*\\nssm-.*\\win64\\nssm.exe" "%WINDIR%" /y}
      )
    end
  end
end
