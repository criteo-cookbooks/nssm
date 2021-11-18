# frozen_string_literal: true

describe service('service name') do
  it { should be_installed }
end

describe command('nssm dump "service name"') do
  its('stdout') { should_not eq '/bad/' }
end
