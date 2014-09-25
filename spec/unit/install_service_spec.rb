require 'spec_helper'

describe 'nssm_test::install_service' do
  let(:chef_run) { ChefSpec::Runner.new(step_into: ['nssm']).converge(described_recipe) }

  let(:fake_class) { Class.new }

  before do
    stub_const('::WIN32OLE', fake_class)
    obj = double
    allow(obj).to receive(:ExecQuery) { [] }
    allow(fake_class).to receive(:connect) { obj }
  end

  it 'calls nssm install resource' do
    expect(chef_run).to install_nssm_service('service name').with(
      program: 'C:\\Windows\\System32\\java.exe',
      args: '-jar C:/path/to/my-executable.jar'
    )
  end

  it 'executes batch command to install service' do
    expect(chef_run).to run_batch('Install service name service').with(
      code: %r{nssm install "service name" C:\\Windows\\System32\\java.exe -jar C:/path/to/my-executable.jar}
    )
  end

  it 'starts service' do
    expect(chef_run).to start_service('service name')
  end
end
