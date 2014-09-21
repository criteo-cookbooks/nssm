require 'spec_helper'

describe 'nssm::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'determines basename from url' do
    expect(chef_run).to write_log('nssm_basename=nssm-2.24')
  end

  it 'downloads and unzips nssm' do
    expect(chef_run).to unzip_windows_zipfile_to(Chef::Config[:file_cache_path]).with(
      source: 'http://nssm.cc/release/nssm-2.24.zip')
  end

  it 'copies nssm executable' do
    expect(chef_run).to run_batch('copy_nssm').with(
      code: /xcopy c:\\chef\\cache\\nssm-2.24\\win32\\nssm.exe %WINDIR% \/y/)
  end
end
