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
        version: '2016',
        step_into: ['nssm']
      ) do
        stub_win32_service_method(:exists?, 'service name', service_exist)
        stub_win32_service_method(:config_info, 'service name', double('config', binary_path_name: binary_path))
      end.converge(described_recipe)
    end

    context 'when the service is not yet installed' do
      it 'calls nssm install resource' do
        expect(chef_run).to install_nssm('service name').with(
          program: "#{DRIVE}\\Windows\\notepad.exe"
        )
      end

      it 'executes command to install service' do
        expect(chef_run).to run_execute('Install service name service').with(
          command: /nssm-#{VERSION}.exe install "service name" #{DRIVE}\\Windows\\notepad.exe/
        )
      end

      it 'sets application' do
        expect(chef_run).to run_execute("Set parameter Application to #{DRIVE}\\Windows\\notepad.exe").with(
          command: /nssm-#{VERSION}.exe set "service name" Application #{DRIVE}\\Windows\\notepad.exe/
        )
      end

      it 'sets start directory parameters' do
        expect(chef_run).to run_execute("Set parameter AppDirectory to #{DRIVE}\\Windows").with(
          command: /nssm-#{VERSION}.exe set "service name" AppDirectory #{DRIVE}\\Windows/
        )
      end

      it 'sets stdout log' do
        expect(chef_run).to run_execute("Set parameter AppStdout to #{DRIVE}\\Windows\\notepad-svc.out").with(
          command: /nssm-#{VERSION}.exe set "service name" AppStdout #{DRIVE}\\Windows\\notepad-svc.out/
        )
      end

      it 'sets stderr log' do
        expect(chef_run).to run_execute("Set parameter AppStderr to #{DRIVE}\\Windows\\notepad-svc.err").with(
          command: /nssm-#{VERSION}.exe set "service name" AppStderr #{DRIVE}\\Windows\\notepad-svc.err/
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
        stub_shellout 'C:\\nssm-2.24-94-g9c88bc1.exe dump "service name"', stdout: <<-STDOUT
          set service name Application C:\\Windows\\notepad.exe
          set service name AppDirectory C:\\Windows
          set service name AppStdout C:\\Windows\\notepad-svc.out
          set service name AppStderr C:\\Windows\\notepad-svc.err
          set service name AppRotateFiles 1
        STDOUT
      end
      let(:service_exist) { true }

      it 'does not execute command to install service' do
        expect(chef_run).to_not run_execute('Install service name service')
      end

      it 'does not set start directory parameters' do
        expect(chef_run).to_not run_execute('Set parameter AppDirectory to C:\\Windows')
      end

      it 'does not set stdout log' do
        expect(chef_run).to_not run_execute('Set parameter AppStdout to C:\\Windows\\notepad-svc.out')
      end

      it 'does not set stderr log' do
        expect(chef_run).to_not run_execute('Set parameter AppStderr to C:\\Windows\\notepad-svc.err')
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

      it 'sets start directory parameters' do
        expect(chef_run).to run_execute("Set parameter AppDirectory to #{DRIVE}\\Windows").with(
          command: /nssm-#{VERSION}.exe set "service name" AppDirectory #{DRIVE}\\Windows/
        )
      end

      it 'sets stdout log' do
        expect(chef_run).to run_execute("Set parameter AppStdout to #{DRIVE}\\Windows\\notepad-svc.out").with(
          command: /nssm-#{VERSION}.exe set "service name" AppStdout #{DRIVE}\\Windows\\notepad-svc.out/
        )
      end

      it 'sets stderr log' do
        expect(chef_run).to run_execute("Set parameter AppStderr to #{DRIVE}\\Windows\\notepad-svc.err").with(
          command: /nssm-#{VERSION}.exe set "service name" AppStderr #{DRIVE}\\Windows\\notepad-svc.err/
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
          file_cache_path: cache_dir, platform: 'centos', version: '7.8.2003', step_into: ['nssm']
        ).converge(described_recipe)
      end

      it 'calls nssm install resource' do
        expect(chef_run).to install_nssm('service name')
      end
    end
  end
end
