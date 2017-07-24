provides :nssm_service, platform: 'windows'
# TODO: migrate to nssm_service with a breaking change notice
provides :nssm, platform: 'windows'

property :servicename, name_attribute: true
property :program, kind_of: String, required: true
property :args, kind_of: String
property :parameters, kind_of: Hash, default: lazy { ::Mash.new }
property :nssm_binary, kind_of: String, default: lazy { ::NSSM.binary_path node }
property :start, kind_of: [TrueClass, FalseClass], default: true
# TODO: add start as default action with a breaking change
default_action :install

load_current_value do |wanted|
  current_value_does_not_exist! unless ::Win32::Service.exists? servicename
  nssm_binary ::Win32::Service.config_info(servicename).binary_path_name

  parameters ::NSSM.dump_parameters(wanted.nssm_binary, servicename)
  next if parameters.empty?

  program parameters['Application']
  args parameters['AppParameters']
end

action :install do
  install_nssm

  # Include action_start's resources to allow notification
  action_start

  execute "Install #{new_resource.servicename} service" do
    command ::NSSM.command(new_resource.nssm_binary, :install, new_resource.servicename, new_resource.program, new_resource.args)
    only_if { current_resource.nil? }
    notifies :start, "service[#{new_resource.servicename}]", :delayed if new_resource.start
  end

  ruby_block "Configure service binary path to #{new_resource.nssm_binary}" do
    block { ::Win32::Service.configure(service_name: new_resource.servicename, binary_path_name: new_resource.nssm_binary) }
    only_if { current_resource && current_resource.nssm_binary != new_resource.nssm_binary }
  end

  params = new_resource.parameters.merge(Application: new_resource.program, AppParameters: new_resource.args)
  params.map do |key, value|
    execute "Set parameter #{key} to #{value}" do
      command ::NSSM.command(new_resource.nssm_binary, :set, new_resource.servicename, key, value)
      not_if { current_resource && current_resource.parameters[key] == ::NSSM.prepare_parameter(value) }
    end
  end
end

action :install_if_missing do
  action_install if current_resource.nil?
end

action :remove do
  # Ensure service is stopped before removing it
  action_stop

  execute "Remove service #{new_resource.servicename}" do
    command ::NSSM.command(new_resource.nssm_binary, :remove, new_resource.servicename, :confirm)
    not_if { current_resource.nil? }
  end
end

action :start do
  # TODO: handle paused state
  service new_resource.servicename do
    action :start
    not_if { current_resource.nil? }
  end
end

action :stop do
  service new_resource.servicename do
    action :stop
    not_if { current_resource.nil? }
  end
end

action_class do
  def whyrun_supported?
    true
  end

  # TODO: Move this into a dedicated resource
  def install_nssm
    return if run_context.loaded_recipe? 'nssm::default'
    recipe_eval do
      run_context.include_recipe 'nssm::default'
    end
  end
end
