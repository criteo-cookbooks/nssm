# frozen_string_literal: true

require 'spec_helper'

describe 'nssm_test::remove_service' do
  context 'windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2008R2', step_into: ['nssm']).converge(described_recipe)
    end

    before do
      stub_shellout('c:\tmp\nssm.exe dump "service name"', error?: false)
    end

    it 'calls nssm remove resource' do
      expect(chef_run).to remove_nssm('service name')
    end

    it 'executes batch command to remove service' do
      expect(chef_run).to run_execute('Remove service service name').with(
        command: /C:\\tmp\\nssm.exe remove "service name" confirm/
      )
    end
  end
end
