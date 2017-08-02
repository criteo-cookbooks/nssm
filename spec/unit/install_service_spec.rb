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

    context 'when the service is not yet installed' do
      before do
        stub_win32_service_method :exists?, 'service name', false
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
          command: %(C:\\tmp\\nssm-#{VERSION}.exe install "service name" C:\\java\\bin\\java.exe) \
            ' -jar C:\\chef\\cache\\selenium-server-standalone-2.53.0.jar'
        )
      end

      it 'sets application' do
        expect(chef_run).to run_execute('Set parameter Application to C:\java\bin\java.exe').with(
          command: %(C:\\tmp\\nssm-#{VERSION}.exe set "service name" Application C:\\java\\bin\\java.exe)
        )
      end

      it 'sets args' do
        expect(chef_run).to run_execute('Set parameter AppParameters to -jar C:\chef\cache\selenium-server-standalone-2.53.0.jar').with(
          command: %(C:\\tmp\\nssm-#{VERSION}.exe set "service name" AppParameters -jar C:\\chef\\cache\\selenium-server-standalone-2.53.0.jar)
        )
      end

      it 'sets start directory parameters' do
        expect(chef_run).to run_execute('Set parameter AppDirectory to C:\chef\cache').with(
          command: %(C:\\tmp\\nssm-#{VERSION}.exe set "service name" AppDirectory C:\\chef\\cache)
        )
      end

      it 'sets stdout log' do
        expect(chef_run).to run_execute('Set parameter AppStdout to C:\chef\cache\service.log').with(
          command: %(C:\\tmp\\nssm-#{VERSION}.exe set "service name" AppStdout C:\\chef\\cache\\service.log)
        )
      end

      it 'sets stderr log' do
        expect(chef_run).to run_execute('Set parameter AppStderr to C:\chef\cache\error.log').with(
          command: %(C:\\tmp\\nssm-#{VERSION}.exe set "service name" AppStderr C:\\chef\\cache\\error.log)
        )
      end

      it 'sets rotate files' do
        expect(chef_run).to run_execute('Set parameter AppRotateFiles to 1').with(
          command: %(C:\\tmp\\nssm-#{VERSION}.exe set "service name" AppRotateFiles 1)
        )
      end

      it 'starts service' do
        expect(chef_run.execute('Install service name service')).to notify('service[service name]')
      end
    end

    context 'when the service is already installed' do
      before do
        stub_win32_service_method :exists?, 'service name', true
        stub_win32_service_method :config_info, 'service name', double('config', binary_path_name: 'c:\tmp\nssm.exe')
      end

      it 'does not execute command to install service' do
        expect(chef_run).to_not run_execute('Install service name service').with(
          command: %(C:\tmp\\nssm-#{VERSION}.exe install "service name" "C:\\java\\bin\\java.exe") \
            ' -jar "C:\\chef\\cache\\selenium-server-standalone-2.53.0.jar"'
        )
      end

      it 'does not set start directory parameters' do
        expect(chef_run).to_not run_execute('Set parameter AppDirectory to C:\\chef\\cache').with(
          command: %(C:\tmp\\nssm-#{VERSION}.exe set "service name" AppDirectory C:\\chef\\cache)
        )
      end

      it 'does not set stdout log' do
        expect(chef_run).to_not run_execute('Set parameter AppStdout to C:\\chef\\cache\\service.log').with(
          command: %(C:\tmp\\nssm-#{VERSION}.exe set "service name" AppStdout C:\\chef\\cache\\service.log)
        )
      end

      it 'does not set stderr log' do
        expect(chef_run).to_not run_execute('Set parameter AppStderr to C:\\chef\\cache\\error.log').with(
          command: %(C:\tmp\\nssm-#{VERSION}.exe set "service name" AppStderr C:\\chef\\cache\\error.log)
        )
      end

      it 'does not set rotate files' do
        expect(chef_run).to_not run_execute('Set parameter AppRotateFiles to 1').with(
          command: %(C:\tmp\\nssm-#{VERSION}.exe set "service name" AppRotateFiles 1)
        )
      end

      it 'does not notifie the service' do
        expect(chef_run.nssm('service name').updated_by_last_action?).to be false
      end
    end

    describe 'when the service is installed with incorrect parameters' do
      before do
        stub_win32_service_method :exists?, 'service name', true
        stub_win32_service_method :config_info, 'service name', double('config', binary_path_name: 'c:\tmp\nssm.exe')
      end

      it 'installs selenium' do
        expect(chef_run).to create_remote_file(File.join(cache_dir, 'selenium-server-standalone-2.53.0.jar'))
      end

      it 'sets start directory parameters' do
        expect(chef_run).to run_execute('Set parameter AppDirectory to C:\\chef\\cache').with(
          command: %(C:\\tmp\\nssm-#{VERSION}.exe set "service name" AppDirectory C:\\chef\\cache)
        )
      end

      it 'sets stdout log' do
        expect(chef_run).to run_execute('Set parameter AppStdout to C:\\chef\\cache\\service.log').with(
          command: %(C:\\tmp\\nssm-#{VERSION}.exe set "service name" AppStdout C:\\chef\\cache\\service.log)
        )
      end

      it 'sets stderr log' do
        expect(chef_run).to run_execute('Set parameter AppStderr to C:\\chef\\cache\\error.log').with(
          command: %(C:\\tmp\\nssm-#{VERSION}.exe set "service name" AppStderr C:\\chef\\cache\\error.log)
        )
      end

      it 'sets rotate files' do
        expect(chef_run).to run_execute('Set parameter AppRotateFiles to 1').with(
          command: %(C:\\tmp\\nssm-#{VERSION}.exe set "service name" AppRotateFiles 1)
        )
      end

      it 'starts service' do
        expect(chef_run).not_to start_service('service name')
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

      it 'calls nssm install resource' do
        expect(chef_run).to install_nssm('service name')
      end
    end
  end
end
