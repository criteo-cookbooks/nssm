action :install do
  service_installed = service_installed?(new_resource.servicename)

  batch "Install service '#{new_resource.servicename}'" do
    code <<-EOH
      nssm install '#{new_resource.servicename}' '#{new_resource.cmd}' #{new_resource.args.join(' ')}
    EOH
    not_if { service_installed }
  end

  if new_resource.start
    service new_resource.servicename do
      action [:start]
      not_if { service_installed }
    end
  end

  new_resource.updated_by_last_action(!service_installed)
end

action :remove do
  service_installed = service_installed?(new_resource.servicename)

  batch "Remove service '#{new_resource.servicename}'" do
    code <<-EOH
      nssm remove '#{new_resource.servicename}' confirm
    EOH
    only_if { service_installed }
  end

  new_resource.updated_by_last_action(service_installed)
end

def service_installed?(servicename)
  !(WMI::Win32_Service.find(:first, conditions: { name: servicename }).nil?)
end
