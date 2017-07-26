# frozen_string_literal: true

# Added by ChefSpec
require 'chefspec'
require 'chefspec/berkshelf'

CACHE = Chef::Config[:file_cache_path]
VERSION = '2.24-94-g9c88bc1'.freeze
SHA256 = '0bbe25025b69ebd8ab263ec4b443513d28a0d072e5fdd9b5cdb327359a27f96e'.freeze

def stub_win32_service_class
  return if defined?(::Win32::Service) && ::Win32::Service.is_a?(::RSpec::Mocks::Double)
  stub_const('::Win32::Service', double('::Win32::Service class'))
end

def stub_win32_service_method(method_name, service_name, *results)
  stub_win32_service_class
  expect(::Win32::Service).to receive(method_name).with(service_name).and_return(*results)
end

def stub_shellout(cmd, options = {})
  default = { live_stream: false, :live_stream= => nil, run_command: nil, stdout: nil }
  options.each { |k, v| default[k.to_sym] = v }
  result = double("shellout for #{cmd}", **default)
  expect(::Mixlib::ShellOut).to receive(:new).and_return result
end

ChefSpec::Coverage.start!
