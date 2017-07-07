# frozen_string_literal: true

require 'spec_helper'

describe 'nssm_test::install_service' do
  context 'windows' do
    let(:cache_dir) { 'C:/chef/cache' }

    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        file_cache_path: cache_dir,
        platform: 'windows',
        version: '2008R2',
        step_into: ['nssm']
      ).converge(described_recipe)
    end

    let(:fake_class) { Class.new }

    context 'when the service is not yet installed' do
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
        ENV['WINDIR'] = 'C:\tmp'

        stub_command(/C:\\tmp\\nssm.exe get .*/).and_return(false)
      end

      it 'installs selenium' do
        expect(chef_run).to create_remote_file(File.join(cache_dir, 'selenium-server-standalone-2.53.0.jar'))
      end

      it 'calls nssm install resource' do
        expect(chef_run).to install_nssm('service name').with(
          program: 'C:\java\bin\java.exe',
          args: %(-jar C:\\chef\\cache\\selenium-server-standalone-2.53.0.jar)
        )
      end

      it 'executes command to install service' do
        expect(chef_run).to run_execute('Install service name service').with(
          command: 'C:\\tmp\\nssm.exe install "service name" "C:\\java\\bin\\java.exe"' \
            ' -jar C:\\chef\\cache\\selenium-server-standalone-2.53.0.jar'
        )
      end

      it 'sets application' do
        expect(chef_run).to run_execute('Set parameter Application to C:\java\bin\java.exe').with(
          command: 'C:\\tmp\\nssm.exe set "service name" Application "C:\java\bin\java.exe"'
        )
      end

      it 'sets args' do
        expect(chef_run).to run_execute('Set parameter AppParameters to -jar C:\chef\cache\selenium-server-standalone-2.53.0.jar').with(
          command: 'C:\\tmp\\nssm.exe set "service name" AppParameters "-jar C:\chef\cache\selenium-server-standalone-2.53.0.jar"'
        )
      end

      it 'sets start directory parameters' do
        expect(chef_run).to run_execute('Set parameter AppDirectory to C:\chef\cache').with(
          command: 'C:\\tmp\\nssm.exe set "service name" AppDirectory "C:\\chef\\cache"'
        )
      end

      it 'sets stdout log' do
        expect(chef_run).to run_execute('Set parameter AppStdout to C:\chef\cache\service.log').with(
          command: 'C:\\tmp\\nssm.exe set "service name" AppStdout "C:\\chef\\cache\\service.log"'
        )
      end

      it 'sets stderr log' do
        expect(chef_run).to run_execute('Set parameter AppStderr to C:\chef\cache\error.log').with(
          command: 'C:\\tmp\\nssm.exe set "service name" AppStderr "C:\\chef\\cache\\error.log"'
        )
      end

      it 'sets rotate files' do
        expect(chef_run).to run_execute('Set parameter AppRotateFiles to 1').with(
          command: 'C:\\tmp\\nssm.exe set "service name" AppRotateFiles "1"'
        )
      end

      it 'starts service' do
        expect(chef_run).to start_service('service name')
      end
    end

    context 'when the service is already installed' do
      before do
        obj = double
        if ENV['APPVEYOR'] # Fix ArgumentError: wrong number of arguments (1 for 0)
          require 'win32ole'
          allow(WIN32OLE).to receive(:connect).with('winmgmts://').and_return(obj)
        else
          stub_const('::WIN32OLE', fake_class)
          allow(fake_class).to receive(:connect).with('winmgmts://').and_return(obj)
        end
        allow(obj).to receive(:ExecQuery).and_return(obj)
        allow(obj).to receive(:each).and_return(obj)
        allow(obj).to receive(:count).and_return(1)
        ENV['SYSTEMDRIVE'] = 'C:'

        stub_command(/C:\\tmp\\nssm.exe get .*/).and_return(true)
      end

      it 'does not execute command to install service' do
        expect(chef_run).to_not run_execute('Install service name service').with(
          command: '"C:\tmp\\nssm.exe install "service name" "C:\\java\\bin\\java.exe"' \
            ' -jar "C:\\chef\\cache\\selenium-server-standalone-2.53.0.jar"'
        )
      end

      it 'does not set start directory parameters' do
        expect(chef_run).to_not run_execute('Set parameter AppDirectory to C:\\chef\\cache').with(
          command: '"C:\tmp\\nssm.exe set "service name" AppDirectory C:\\chef\\cache'
        )
      end

      it 'does not set stdout log' do
        expect(chef_run).to_not run_execute('Set parameter AppStdout to C:\\chef\\cache\\service.log').with(
          command: '"C:\tmp\\nssm.exe set "service name" AppStdout C:\\chef\\cache\\service.log'
        )
      end

      it 'does not set stderr log' do
        expect(chef_run).to_not run_execute('Set parameter AppStderr to C:\\chef\\cache\\error.log').with(
          command: '"C:\tmp\\nssm.exe set "service name" AppStderr C:\\chef\\cache\\error.log'
        )
      end

      it 'does not set rotate files' do
        expect(chef_run).to_not run_execute('Set parameter AppRotateFiles to 1').with(
          command: '"C:\tmp\\nssm.exe set "service name" AppRotateFiles 1'
        )
      end

      it 'does not notifie the service' do
        expect(chef_run.nssm('service name').updated_by_last_action?).to be false
      end
    end

    describe 'when the service is installed with incorrect parameters' do
      before do
        obj = double
        if ENV['APPVEYOR'] # Fix ArgumentError: wrong number of arguments (1 for 0)
          require 'win32ole'
          allow(WIN32OLE).to receive(:connect).with('winmgmts://').and_return(obj)
        else
          stub_const('::WIN32OLE', fake_class)
          allow(fake_class).to receive(:connect).with('winmgmts://').and_return(obj)
        end
        allow(obj).to receive(:ExecQuery).and_return(obj)
        allow(obj).to receive(:each).and_return(obj)
        allow(obj).to receive(:count).and_return(1)
        ENV['SYSTEMDRIVE'] = 'C:'

        stub_command(/C:\\tmp\\nssm.exe get .*/).and_return(false)
      end

      it 'installs selenium' do
        expect(chef_run).to create_remote_file(File.join(cache_dir, 'selenium-server-standalone-2.53.0.jar'))
      end

      it 'sets start directory parameters' do
        expect(chef_run).to run_execute('Set parameter AppDirectory to C:\\chef\\cache').with(
          command: 'C:\\tmp\\nssm.exe set "service name" AppDirectory "C:\\chef\\cache"'
        )
      end

      it 'sets stdout log' do
        expect(chef_run).to run_execute('Set parameter AppStdout to C:\\chef\\cache\\service.log').with(
          command: 'C:\\tmp\\nssm.exe set "service name" AppStdout "C:\\chef\\cache\\service.log"'
        )
      end

      it 'sets stderr log' do
        expect(chef_run).to run_execute('Set parameter AppStderr to C:\\chef\\cache\\error.log').with(
          command: 'C:\\tmp\\nssm.exe set "service name" AppStderr "C:\\chef\\cache\\error.log"'
        )
      end

      it 'sets rotate files' do
        expect(chef_run).to run_execute('Set parameter AppRotateFiles to 1').with(
          command: 'C:\\tmp\\nssm.exe set "service name" AppRotateFiles "1"'
        )
      end

      it 'starts service' do
        expect(chef_run).to start_service('service name')
      end
    end

    context 'linux' do
      let(:cache_dir) { '/var/chef/cache' }
      let(:chef_run) do
        ChefSpec::SoloRunner.new(
          file_cache_path: cache_dir, platform: 'centos', version: '7.3.1611', step_into: ['nssm']
        ).converge(described_recipe)
      end

      it 'installs selenium' do
        expect(chef_run).to create_remote_file(::File.join(cache_dir, 'selenium-server-standalone-2.53.0.jar'))
      end
    end
  end
end
