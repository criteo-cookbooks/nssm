# frozen_string_literal: true

use_inline_resources

require 'win32ole' if RUBY_PLATFORM =~ /mswin|mingw32|windows/

def execute_wmi_query(wmi_query)
  wmi = ::WIN32OLE.connect('winmgmts://')
  result = wmi.ExecQuery(wmi_query)
  result.each.count > 0
end

def service_installed?(servicename)
  execute_wmi_query("select * from Win32_Service where name = '#{servicename}'")
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

  service_installed = service_installed?(new_resource.servicename)

  execute "Install #{new_resource.servicename} service" do
    command "#{nssm_exe} install \"#{new_resource.servicename}\" \"#{new_resource.program}\" #{new_resource.args}"
    not_if { service_installed }
  end

  parameters = new_resource.parameters.merge(
    'Application' => new_resource.program,
    'AppParameters' => new_resource.args
  )

  parameters.map do |k, v|
    execute "Set parameter #{k} to #{v}" do
      command "#{nssm_exe} set \"#{new_resource.servicename}\" #{k} \"#{v.to_s.gsub('"', '""').strip}\""
      not_if "#{nssm_exe} get \"#{new_resource.servicename}\" #{k} | grep -F -- \"#{v.to_s.gsub('"', '""').strip}\""
    end
  end

  service new_resource.servicename do # ~FC021
    action [:start]
    only_if { new_resource.start }
  end
end

action :remove do
  if platform?('windows')
    service_installed = service_installed?(new_resource.servicename)

    execute "Remove service #{new_resource.servicename}" do
      command "#{nssm_exe} remove \"#{new_resource.servicename}\" confirm"
      only_if { service_installed }
    end
  else
    Chef::Log.warn('NSSM service can only be removed from Windows platforms!')
  end
end
