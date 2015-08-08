require 'spec_helper'

describe 'nssm::default' do
  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2008R2').converge(described_recipe)
    end

    it 'determines basename from url' do
      expect(chef_run).to write_log('nssm_basename=nssm-2.24')
    end

    it 'downloads and unzips nssm' do
      expect(chef_run).to unzip_windows_zipfile_to(Chef::Config[:file_cache_path]).with(
        source: 'http://nssm.cc/release/nssm-2.24.zip')
    end

    it 'copies nssm executable' do
      expect(chef_run).to run_batch('copy_nssm').with(
        code: %r{xcopy .*\\nssm-2.24\\win64\\nssm.exe "%WINDIR%" /y})
    end
  end

  context 'linux' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0').converge(described_recipe) }

    it 'writes a log with warning' do
      expect(chef_run).to write_log('NSSM can only be installed on Windows platforms!').with(level: :warn)
    end
  end
end
