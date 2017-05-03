require 'spec_helper'

describe 'nssm::default' do
  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        file_cache_path: CACHE, platform: 'windows', version: '2008R2'
      ).converge(described_recipe)
    end

    it 'downloads nssm' do
      expect(chef_run).to create_remote_file(
        "download #{CACHE}/nssm-#{VERSION}.zip"
      ).with(
        path: "#{CACHE}/nssm-#{VERSION}.zip",
        source: "http://nssm.cc/release/nssm-#{VERSION}.zip"
      )
    end

    it 'unzips nssm' do
      expect(chef_run).to_not run_powershell_script(
        "unzip #{CACHE}/nssm-#{VERSION}.zip"
      )
    end

    it 'installs nssm' do
      expect(chef_run).to_not run_batch('install nssm').with(
        code: %r{xcopy ".*\\nssm-.*\\win64\\nssm.exe" "%WINDIR%" /y}
      )
    end
  end

  context 'linux' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0').converge(described_recipe) }

    it 'writes a log with warning' do
      expect(chef_run).to write_log('NSSM can only be installed on Windows platforms!').with(level: :warn)
    end
  end
end
