provides :nssm_service, platform: 'windows'
unified_mode true
# TODO: migrate to nssm_service with a breaking change notice
provides :nssm, platform: 'windows'

property :servicename, kind_of: String, name_property: true
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
  nssm_install 'Install NSSM' do
    source node['nssm']['src']
    sha256 node['nssm']['sha256']
    only_if { node['nssm']['install_nssm'] }
  end

  # Declare the service for start notification
  service new_resource.servicename

  # Some NSSM parameters have no meaningful default, list them here to prevent errors on reset command
  params_no_default = ' Application AppDirectory DisplayName ObjectName Start Type AppEvents '
  needs_sub_param = ' AppExit '
  sub_param_defaults = { 'AppExit' => 'Default Restart' }

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
    value = "Default #{value}" if needs_sub_param.include?(key.to_s) && (value !~ /^Default /i)
    execute "Set parameter #{key} to #{value}" do
      command ::NSSM.command(new_resource.nssm_binary, :set, new_resource.servicename, key, value)
      not_if { current_resource && current_resource.parameters[key.to_s] == ::NSSM.prepare_for_compare(key, value) }
      # not_if { current_resource && current_resource.parameters[key] == ::NSSM.prepare_parameter(value) }
    end
  end

  current_resource.parameters.each do |key, value|
    # Skip if user defined value is supplied to resource
    next if params.key?(key.to_sym) | params.key?(key.to_s)
    # Skip if parameter has no default
    next if params_no_default.include?(key)
    case needs_sub_param.include?(key)
    when false
      execute "Reset parameter #{key} to default" do
        command ::NSSM.command(new_resource.nssm_binary, :reset, new_resource.servicename, key)
      end
    when true
      execute "Reset parameter #{key} to default with default subparameter" do
        command ::NSSM.command(new_resource.nssm_binary, :reset, new_resource.servicename, key, 'default')
        # not_if it is already set to it's default value
        not_if { sub_param_defaults.key?(key) && sub_param_defaults[key] == ::NSSM.prepare_for_compare(key, value) }
      end
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

action_class do
end
