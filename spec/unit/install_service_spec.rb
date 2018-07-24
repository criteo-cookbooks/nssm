# frozen_string_literal: true

require 'spec_helper'

describe 'nssm_test::install_service' do
  context 'windows' do
    let(:cache_dir) { 'C:/chef/cache' }
    let(:service_exist) { false }
    let(:binary_path) { "#{DRIVE}\\nssm-#{VERSION}.exe" }
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        file_cache_path: cache_dir,
        platform: 'windows',
        version: '2008R2',
        step_into: ['nssm']
      ) do
        stub_win32_service_method(:exists?, 'service name', service_exist)
        stub_win32_service_method(:config_info, 'service name', double('config', binary_path_name: binary_path))
      end.converge(described_recipe)
    end

    context 'when the service is not yet installed' do
      it 'installs selenium' do
        expect(chef_run).to create_remote_file(File.join(cache_dir, 'selenium-server-standalone-2.53.0.jar'))
      end

      it 'calls nssm install resource' do
        expect(chef_run).to install_nssm('service name').with(
          program: "#{DRIVE}\\java\\bin\\java.exe",
          args: %(-jar C:\\chef\\cache\\selenium-server-standalone-2.53.0.jar)
        )
      end

      it 'executes command to install service' do
        expect(chef_run).to run_execute('Install service name service').with(
          command: /nssm-#{VERSION}.exe install "service name" #{DRIVE}\\java\\bin\\java.exe -jar C:\\chef\\cache\\selenium-server-standalone-2.53.0.jar/
        )
      end

      it 'sets application' do
        expect(chef_run).to run_execute("Set parameter Application to #{DRIVE}\\java\\bin\\java.exe").with(
          command: /nssm-#{VERSION}.exe set "service name" Application #{DRIVE}\\java\\bin\\java.exe/
        )
      end

      it 'sets args' do
        expect(chef_run).to run_execute('Set parameter AppParameters to -jar C:\chef\cache\selenium-server-standalone-2.53.0.jar').with(
          command: /nssm-#{VERSION}.exe set "service name" AppParameters -jar C:\\chef\\cache\\selenium-server-standalone-2.53.0.jar/
        )
      end

      it 'sets start directory parameters' do
        expect(chef_run).to run_execute('Set parameter AppDirectory to C:\chef\cache').with(
          command: /nssm-#{VERSION}.exe set "service name" AppDirectory C:\\chef\\cache/
        )
      end

      it 'sets stdout log' do
        expect(chef_run).to run_execute('Set parameter AppStdout to C:\chef\cache\service.log').with(
          command: /nssm-#{VERSION}.exe set "service name" AppStdout C:\\chef\\cache\\service.log/
        )
      end

      it 'sets stderr log' do
        expect(chef_run).to run_execute('Set parameter AppStderr to C:\chef\cache\error.log').with(
          command: /nssm-#{VERSION}.exe set "service name" AppStderr C:\\chef\\cache\\error.log/
        )
      end

      it 'sets rotate files' do
        expect(chef_run).to run_execute('Set parameter AppRotateFiles to 1').with(
          command: /nssm-#{VERSION}.exe set "service name" AppRotateFiles 1/
        )
      end

      it 'starts service' do
        expect(chef_run.execute('Install service name service')).to notify('service[service name]')
      end
    end

    context 'when the service is already installed' do
      before do
        stub_shellout '\\nssm-2.24-94-g9c88bc1.exe dump "service name"', stdout: <<-STDOUT
          set service name Application xxx
          set service name AppDirectory C:\\chef\\cache
          set service name AppStdout C:\\chef\\cache\\service.log
          set service name AppStderr C:\\chef\\cache\\error.log
          set service name AppRotateFiles 1
        STDOUT
      end
      let(:service_exist) { true }

      it 'does not execute command to install service' do
        expect(chef_run).to_not run_execute('Install service name service')
      end

      it 'does not set start directory parameters' do
        expect(chef_run).to_not run_execute('Set parameter AppDirectory to C:\\chef\\cache')
      end

      it 'does not set stdout log' do
        expect(chef_run).to_not run_execute('Set parameter AppStdout to C:\\chef\\cache\\service.log')
      end

      it 'does not set stderr log' do
        expect(chef_run).to_not run_execute('Set parameter AppStderr to C:\\chef\\cache\\error.log')
      end

      it 'does not set rotate files' do
        expect(chef_run).to_not run_execute('Set parameter AppRotateFiles to 1')
      end

      it 'does not notifie the service' do
        expect(chef_run.nssm('service name').updated_by_last_action?).to be false
      end
    end

    describe 'when the service is installed with incorrect parameters' do
      let(:service_exist) { true }
      let(:binary_path) { 'c:\tmp\nssm.exe' }

      it 'installs selenium' do
        expect(chef_run).to create_remote_file(File.join(cache_dir, 'selenium-server-standalone-2.53.0.jar'))
      end

      it 'sets start directory parameters' do
        expect(chef_run).to run_execute('Set parameter AppDirectory to C:\\chef\\cache').with(
          command: /nssm-#{VERSION}.exe set "service name" AppDirectory C:\\chef\\cache/
        )
      end

      it 'sets stdout log' do
        expect(chef_run).to run_execute('Set parameter AppStdout to C:\\chef\\cache\\service.log').with(
          command: /nssm-#{VERSION}.exe set "service name" AppStdout C:\\chef\\cache\\service.log/
        )
      end

      it 'sets stderr log' do
        expect(chef_run).to run_execute('Set parameter AppStderr to C:\\chef\\cache\\error.log').with(
          command: /nssm-#{VERSION}.exe set "service name" AppStderr C:\\chef\\cache\\error.log/
        )
      end

      it 'sets rotate files' do
        expect(chef_run).to run_execute('Set parameter AppRotateFiles to 1').with(
          command: /nssm-#{VERSION}.exe set "service name" AppRotateFiles 1/
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
