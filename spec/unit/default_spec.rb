# frozen_string_literal: true

require 'spec_helper'

describe 'nssm::default' do
  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        file_cache_path: CACHE, platform: 'windows', version: '2008R2', step_into: ['nssm_install']
      ) do
        ENV['WINDIR'] = 'C:\tmp'
      end.converge(described_recipe)
    end

    it 'calls nssm_install resource' do
      expect(chef_run).to install_nssm_install('Install NSSM').with(
        source: "https://nssm.cc/ci/nssm-#{VERSION}.zip",
        sha256: SHA256
      )
    end

    it 'download nssm' do
      expect(chef_run).to unzip_windows_zipfile('download nssm').with(
        path: CACHE,
        source: "https://nssm.cc/ci/nssm-#{VERSION}.zip"
      )
    end

    it 'install nssm' do
      expect(chef_run).to create_remote_file('install nssm').with(
        path: "C:\\tmp\\nssm-#{VERSION}.exe",
        source: "file:///#{CACHE}/nssm-2.24-94-g9c88bc1/win64/nssm.exe"
      )
    end
  end
end
