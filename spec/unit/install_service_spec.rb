require 'spec_helper'

describe 'nssm_test::install_service' do
  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        file_cache_path: 'C:\chef\cache',
        platform: 'windows',
        version: '2008R2',
        step_into: ['nssm']
      ).converge(described_recipe)
    end

    let(:fake_class) { Class.new }

    before do
      stub_const('::WIN32OLE', fake_class)
      obj = double
      allow(fake_class).to receive(:connect) { obj }
      allow(obj).to receive(:ExecQuery) { [] }
      ENV['SYSTEMDRIVE'] = 'C:'
    end

    it 'calls nssm install resource' do
      expect(chef_run).to install_nssm('service name').with(
        program: 'C:\java\bin\java.exe',
        args: '-jar C:\chef\cache\selenium-server-standalone-2.53.0.jar'
      )
    end

    it 'executes batch command to install service' do
      expect(chef_run).to run_batch('Install service name service').with(
        code: /%WINDIR%\\nssm.exe install "service name" "C:\\java\\bin\\java.exe" \
-jar C:\\chef\\cache\\selenium-server-standalone-2.53.0.jar/
      )
    end

    it 'sets start directory parameters' do
      expect(chef_run).to run_batch('Set parameter AppDirectory C:\\chef\\cache').with(
        code: /%WINDIR%\\nssm.exe set "service name" AppDirectory C:\\chef\\cache/
      )
    end

    it 'sets service parameters' do
      expect(chef_run).to run_batch('Set parameter AppStdout C:\\chef\\cache\\service.log').with(
        code: /%WINDIR%\\nssm.exe set "service name" AppStdout C:\\chef\\cache\\service.log/
      )
    end

    it 'sets service parameters' do
      expect(chef_run).to run_batch('Set parameter AppStderr C:\\chef\\cache\\error.log').with(
        code: /%WINDIR%\\nssm.exe set "service name" AppStderr C:\\chef\\cache\\error.log/
      )
    end

    it 'sets service parameters' do
      expect(chef_run).to run_batch('Set parameter AppRotateFiles 1').with(
        code: /%WINDIR%\\nssm.exe set "service name" AppRotateFiles 1/
      )
    end

    it 'starts service' do
      expect(chef_run).to start_service('service name')
    end
  end

  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: ['nssm']).converge(described_recipe)
    end

    it 'writes a log with warning' do
      expect(chef_run).to write_log('NSSM service can only be installed on Windows platforms!').with(level: :warn)
    end
  end
end
