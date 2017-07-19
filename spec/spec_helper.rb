# frozen_string_literal: true

# Added by ChefSpec
require 'chefspec'
require 'chefspec/berkshelf'

CACHE = Chef::Config[:file_cache_path]
VERSION = '2.24-94-g9c88bc1'.freeze

def stub_shellout(cmd, options = {})
  default = { live_stream: false, :live_stream= => nil, run_command: nil, stdout: nil }
  options.each { |k, v| default[k.to_sym] = v }
  result = double("shellout for #{cmd}", **default)
  expect(::Mixlib::ShellOut).to receive(:new).and_return result
end

ChefSpec::Coverage.start!
