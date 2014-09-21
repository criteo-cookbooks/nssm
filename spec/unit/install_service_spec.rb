require 'spec_helper'

describe 'nssm_test::install_service' do
  let(:chef_run) { ChefSpec::Runner.new(step_into: ['nssm']).converge(described_recipe) }

  let(:fake_class) { Class.new }

  before do
    stub_const('WMI::Win32_Service', fake_class)
    allow(fake_class).to receive(:find) { nil }
  end

  it 'calls nssm install resource' do
    expect(chef_run).to install_nssm_service('service name').with(
      app: 'java',
      args: ['-jar', "'C:\\path to\\my-executable.jar'"]
    )
  end

  it 'executes batch command to install service' do
    expect(chef_run).to run_batch('Install service service name').with(
      code: /nssm install 'service name' 'java' -jar 'C:\\path to\\my-executable.jar'/
    )
  end

  it 'starts service' do
    expect(chef_run).to start_service('service name')
  end
end
