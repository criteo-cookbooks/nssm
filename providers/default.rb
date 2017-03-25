require 'win32ole' if RUBY_PLATFORM =~ /mswin|mingw32|windows/

use_inline_resources

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

action :install do
  if platform?('windows')
    install_nssm
    service_installed = service_installed?(new_resource.servicename)

    batch "Install #{new_resource.servicename} service" do
      code "#{nssm_exe} install \"#{new_resource.servicename}\" \"#{new_resource.program}\" #{new_resource.args}"
      not_if { service_installed }
    end

    unless service_installed
      new_resource.parameters.map do |k, v|
        batch "Set parameter #{k} #{v}" do
          code "#{nssm_exe} set \"#{new_resource.servicename}\" #{k} #{v}"
        end
      end
    end

    if new_resource.start
      service new_resource.servicename do
        action [:start]
        not_if { service_installed }
      end
    end
  else
    log('NSSM service can only be installed on Windows platforms!') { level :warn }
  end
end

action :remove do
  if platform?('windows')
    service_installed = service_installed?(new_resource.servicename)

    batch "Remove service #{new_resource.servicename}" do
      code "#{nssm_exe} remove \"#{new_resource.servicename}\" confirm"
      only_if { service_installed }
    end
  else
    log('NSSM service can only be removed from Windows platforms!') { level :warn }
  end
end
