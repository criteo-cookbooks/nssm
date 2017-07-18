# frozen_string_literal: true

use_inline_resources

def whyrun_supported?
  true
end

def install_nssm
  return if run_context.loaded_recipe? 'nssm::default'
  recipe_eval do
    run_context.include_recipe 'nssm::default'
  end
end

def nssm_exe
  "#{node['nssm']['install_location']}\\nssm.exe"
end

action :install_if_missing do
  return Chef::Log.warn('NSSM service can only be installed on Windows platforms!') unless platform?('windows')

  install_nssm
  service_installed = ::Win32::Service.exists? new_resource.servicename

  execute "Install #{new_resource.servicename} service" do
    command "#{nssm_exe} install \"#{new_resource.servicename}\" \"#{new_resource.program}\" #{new_resource.args}"
    not_if { service_installed }
  end

  new_resource.parameters.map do |k, v|
    execute "Set parameter #{k} #{v}" do
      command "#{nssm_exe} set \"#{new_resource.servicename}\" #{k} \"#{v.gsub('"', '^"').strip}\""
      not_if { service_installed }
    end
  end

  service new_resource.servicename do # ~FC021
    action [:start]
    only_if { new_resource.start }
  end
end

action :install do
  return Chef::Log.warn('NSSM service can only be installed on Windows platforms!') unless platform?('windows')

  install_nssm
  service_installed = ::Win32::Service.exists? new_resource.servicename

  execute "Install #{new_resource.servicename} service" do
    command "#{nssm_exe} install \"#{new_resource.servicename}\" \"#{new_resource.program}\" #{new_resource.args}"
    not_if { service_installed }
  end

  parameters = new_resource.parameters.merge(
    'Application' => new_resource.program,
    'AppParameters' => new_resource.args
  )

  parameters.map do |k, v|
    value = v.to_s.gsub('"', '^"').strip
    execute "Set parameter #{k} to #{value}" do
      command "#{nssm_exe} set \"#{new_resource.servicename}\" #{k} \"#{value}\""
      not_if "#{nssm_exe} get \"#{new_resource.servicename}\" #{k} | findstr /BEC:\"#{value}\""
    end
  end

  service new_resource.servicename do # ~FC021
    action [:start]
    only_if { new_resource.start }
  end
end

action :remove do
  if platform?('windows')
    service_installed = ::Win32::Service.exists? new_resource.servicename

    execute "Remove service #{new_resource.servicename}" do
      command "#{nssm_exe} remove \"#{new_resource.servicename}\" confirm"
      only_if { service_installed }
    end
  else
    Chef::Log.warn('NSSM service can only be removed from Windows platforms!')
  end
end
