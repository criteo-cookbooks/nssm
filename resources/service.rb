provides :nssm_service, platform: 'windows'
# TODO: migrate to nssm_service with a breaking change notice
provides :nssm, platform: 'windows'

unified_mode true

property :servicename, String, name_property: true
property :program, String, required: true
property :args, String
property :parameters, Hash, default: lazy { ::Mash.new }
property :nssm_binary, [String, NilClass], default: lazy { ::NSSM.binary_path node }
property :start, [true, false], default: true
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
  nssm_install 'Install NSSM' do
    source node['nssm']['src']
    sha256 node['nssm']['sha256']
    only_if { node['nssm']['install_nssm'] }
  end

  # Declare the service for start notification
  service new_resource.servicename

  execute "Install #{new_resource.servicename} service" do
    command ::NSSM.command(new_resource.nssm_binary, :install, new_resource.servicename, new_resource.program, new_resource.args)
    only_if { current_resource.nil? }
    notifies :start, "service[#{new_resource.servicename}]", :delayed if new_resource.start
  end

  ruby_block "Configure service binary path to #{new_resource.nssm_binary}" do
    block { ::Win32::Service.configure(service_name: new_resource.servicename, binary_path_name: new_resource.nssm_binary) }
    only_if { current_resource && current_resource.nssm_binary != new_resource.nssm_binary }
  end

  params = new_resource.parameters.merge(Application: new_resource.program)
  params = params.merge(AppParameters: new_resource.args) unless new_resource.args.nil?
  params.each do |key, value|
    execute "Set parameter #{key} to #{value}" do
      command ::NSSM.command(new_resource.nssm_binary, :set, new_resource.servicename, key, value)
      not_if { current_resource && current_resource.parameters[key] == ::NSSM.prepare_parameter(value) }
    end
  end

  # Some NSSM parameters have no meaningful default, list them here to prevent errors on reset command
  params_no_default = ' Application AppDirectory DisplayName ObjectName Start Type '
  needs_sub_param = ' AppExit '

  current_resource.parameters.each do |key, _value|
    execute "Reset parameter #{key} to default" do
      command ::NSSM.command(new_resource.nssm_binary, :reset, new_resource.servicename, key)
      not_if { params.key?(key.to_sym) || params_no_default.include?(key) || needs_sub_param.include?(key) }
    end
    execute "Reset parameter #{key} to default with default subparameter" do
      command ::NSSM.command(new_resource.nssm_binary, :reset, new_resource.servicename, key, 'default')
      only_if { needs_sub_param.include?(key) }
    end
  end unless current_resource.nil?
end

action :install_if_missing do
  action_install if current_resource.nil?
end

action :remove do
  # Declare the service for stop notification
  service new_resource.servicename

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
