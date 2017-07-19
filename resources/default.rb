# frozen_string_literal: true

actions :install, :install_if_missing, :remove
default_action :install

provides 'nssm'

property :servicename, name_attribute: true
property :program, kind_of: String, required: true
property :args, kind_of: String
property :parameters, kind_of: Hash, default: lazy { ::Mash.new }
property :nssm_binary, kind_of: String, default: lazy { "#{node['nssm']['install_location']}\\nssm.exe" }
property :start, kind_of: [TrueClass, FalseClass], default: true

include ::Chef::Mixin::ShellOut
include ::NSSM::ParameterHelper

load_current_value do
  cmd = shell_out %(#{nssm_binary} dump "#{prepare_parameter servicename}")
  current_value_does_not_exist! if cmd.error?

  cmd.stdout.to_s.split(/\r?\n/) do |line|
    case line
    when /nssm.exe install #{servicename}/
      program strip_and_unescape(line.split(servicename, 2).last)
      parameters['Application'] = program
    when /nssm.exe set #{servicename}/
      param, value = line.split(servicename, 2).last.split(' ', 2)
      parameters[param] = strip_and_unescape value
    end
  end
  args parameters['AppParameters']
end

action :install_if_missing do
  return Chef::Log.warn('NSSM service can only be installed on Windows platforms!') unless platform?('windows')

  run_action :install if current_resource.nil?
end

action :install do
  return Chef::Log.warn('NSSM service can only be installed on Windows platforms!') unless platform?('windows')

  install_nssm

  execute "Install #{new_resource.servicename} service" do
    command "#{nssm_binary} install \"#{new_resource.servicename}\" \"#{new_resource.program}\" #{new_resource.args}"
    not_if { current_resource.nil? }
  end

  parameters = new_resource.parameters.merge(
    'Application' => new_resource.program,
    'AppParameters' => new_resource.args
  )

  parameters.map do |k, v|
    value = v.to_s.gsub('"', '^"').strip
    execute "Set parameter #{k} to #{value}" do
      command "#{nssm_binary} set \"#{new_resource.servicename}\" #{k} \"#{value}\""
      not_if "#{nssm_binary} get \"#{new_resource.servicename}\" #{k} | findstr /BEC:\"#{value}\""
    end
  end

  service new_resource.servicename do # ~FC021
    action [:start]
    only_if { new_resource.start }
  end
end

action :remove do
  if platform?('windows')
    execute "Remove service #{new_resource.servicename}" do
      command "#{nssm_binary} remove \"#{new_resource.servicename}\" confirm"
      only_if { current_resource.nil? }
    end
  else
    Chef::Log.warn('NSSM service can only be removed from Windows platforms!')
  end
end

action_class do
  def whyrun_supported?
    true
  end

  def install_nssm
    return if run_context.loaded_recipe? 'nssm::default'
    recipe_eval do
      run_context.include_recipe 'nssm::default'
    end
  end
end
