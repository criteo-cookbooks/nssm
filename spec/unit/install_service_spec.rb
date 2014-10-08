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
    expect(chef_run).to install_nssm('service name').with(
      program: 'C:\\Windows\\System32\\java.exe',
      args: '-jar C:/path/to/my-executable.jar'
    )
  end

  it 'executes batch command to install service' do
    expect(chef_run).to run_batch('Install service name service').with(
      code: %r{nssm install "service name" "C:\\Windows\\System32\\java.exe" -jar C:/path/to/my-executable.jar}
    )
  end

  it 'sets start directory parameters' do
    expect(chef_run).to run_batch('Set parameter AppDirectory C:/path/to').with(
      code: %r{nssm set "service name" AppDirectory C:/path/to}
    )
  end

  it 'sets service parameters' do
    expect(chef_run).to run_batch('Set parameter AppStdout C:/path/to/log/service.log').with(
      code: %r{nssm set "service name" AppStdout C:/path/to/log/service.log}
    )
  end

  it 'sets service parameters' do
    expect(chef_run).to run_batch('Set parameter AppStderr C:/path/to/log/error.log').with(
      code: %r{nssm set "service name" AppStderr C:/path/to/log/error.log}
    )
  end

  it 'sets service parameters' do
    expect(chef_run).to run_batch('Set parameter AppRotateFiles 1').with(
      code: /nssm set "service name" AppRotateFiles 1/
    )
  end

  it 'starts service' do
    expect(chef_run).to start_service('service name')
  end
end
