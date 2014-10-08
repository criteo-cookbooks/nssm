require 'spec_helper'

describe 'nssm_test::remove_service' do
  let(:chef_run) { ChefSpec::Runner.new(step_into: ['nssm']).converge(described_recipe) }

  let(:fake_class) { Class.new }

  before do
    stub_const('::WIN32OLE', fake_class)
    obj = double
    allow(obj).to receive(:ExecQuery) { [''] }
    allow(fake_class).to receive(:connect) { obj }
  end

  it 'calls nssm remove resource' do
    expect(chef_run).to remove_nssm('service name')
  end

  it 'executes batch command to remove service' do
    expect(chef_run).to run_batch('Remove service service name').with(
      code: /nssm remove "service name" confirm/
    )
  end
end
