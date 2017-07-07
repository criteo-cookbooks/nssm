# frozen_string_literal: true

require 'spec_helper'

describe 'nssm_test::remove_service' do
  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2008R2', step_into: ['nssm']).converge(described_recipe)
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
      allow(obj).to receive(:ExecQuery).and_return([''])
      ENV['SYSTEMDRIVE'] = 'C:'
    end

    it 'calls nssm remove resource' do
      expect(chef_run).to remove_nssm('service name')
    end

    it 'executes batch command to remove service' do
      expect(chef_run).to run_batch('Remove service service name').with(
        code: /%WINDIR%\\nssm.exe remove "service name" confirm/
      )
    end
  end

  context 'linux' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0', step_into: ['nssm']).converge(described_recipe)
    end

    it 'writes a log with warning' do
      expect(chef_run).to write_log('NSSM service can only be removed from Windows platforms!').with(level: :warn)
    end
  end
end
