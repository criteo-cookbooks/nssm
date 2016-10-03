require 'spec_helper'

describe 'nssm_test::install_service' do
  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        file_cache_path: CACHE,
        platform: 'windows',
        version: '2008R2',
        step_into: ['nssm']
      ).converge(described_recipe)
    end

    let(:fake_class) { Class.new }

    before do
      obj = double
      if ENV['APPVEYOR'] # Fix ArgumentError: wrong number of arguments (1 for 0)
        require 'win32ole'
        allow(WIN32OLE).to receive(:connect).with('winmgmts://').and_return(obj)
      else
        stub_const('::WIN32OLE', fake_class)
        allow(fake_class).to receive(:connect).with('winmgmts://').and_return(obj)
      end
      allow(obj).to receive(:ExecQuery).and_return([])
      ENV['SYSTEMDRIVE'] = 'C:'
    end

    it 'installs selenium' do
      expect(chef_run).to create_remote_file("#{CACHE}\\selenium-server-standalone-2.53.0.jar")
    end

    it 'calls nssm install resource' do
      expect(chef_run).to install_nssm('service name').with(
        program: 'C:\java\bin\java.exe',
        args: "-jar #{CACHE}\\selenium-server-standalone-2.53.0.jar"
      )
    end

    it 'executes batch command to install service' do
      expect(chef_run).to run_batch('Install service name service').with(
        code: '%WINDIR%\\nssm.exe install "service name" "C:\\java\\bin\\java.exe"' \
          " -jar #{CACHE}\\selenium-server-standalone-2.53.0.jar"
      )
    end

    it 'sets start directory parameters' do
      expect(chef_run).to run_batch("Set parameter AppDirectory #{CACHE}").with(
        code: "%WINDIR%\\nssm.exe set \"service name\" AppDirectory #{CACHE}"
      )
    end

    it 'sets stdout log' do
      expect(chef_run).to run_batch("Set parameter AppStdout #{CACHE}\\service.log").with(
        code: "%WINDIR%\\nssm.exe set \"service name\" AppStdout #{CACHE}\\service.log"
      )
    end

    it 'sets stderr log' do
      expect(chef_run).to run_batch("Set parameter AppStderr #{CACHE}\\error.log").with(
        code: "%WINDIR%\\nssm.exe set \"service name\" AppStderr #{CACHE}\\error.log"
      )
    end

    it 'sets rotate files' do
      expect(chef_run).to run_batch('Set parameter AppRotateFiles 1').with(
        code: '%WINDIR%\\nssm.exe set "service name" AppRotateFiles 1'
      )
    end

    it 'starts service' do
      expect(chef_run).to start_service('service name')
    end
  end

  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        file_cache_path: CACHE, platform: 'centos', version: '7.0', step_into: ['nssm']
      ).converge(described_recipe)
    end

    it 'installs selenium' do
      expect(chef_run).to create_remote_file("#{CACHE}\\selenium-server-standalone-2.53.0.jar")
    end

    it 'writes a log with warning' do
      expect(chef_run).to write_log('NSSM service can only be installed on Windows platforms!').with(level: :warn)
    end
  end
end
