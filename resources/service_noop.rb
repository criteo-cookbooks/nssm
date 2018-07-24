provides :nssm_service
provides :nssm # TODO: migrate to nssm_service with a breaking change notice

property :servicename, String, identity: true, name_property: true
property :program, String, required: true
property :args, String
property :parameters, Hash, default: lazy { ::Mash.new }
property :nssm_binary, [String, NilClass], default: nil
# TODO: remove this
property :start, [TrueClass, FalseClass], default: true

action :install do
  ::Chef::Log.warn('NSSM service can only be installed on Windows platforms!')
end

action :install_if_missing do
  ::Chef::Log.warn('NSSM service can only be installed on Windows platforms!')
end

action :remove do
  ::Chef::Log.warn('NSSM service can only be removed on Windows platforms!')
end

action :start do
  ::Chef::Log.warn('NSSM service can only be started on Windows platforms!')
end

action :stop do
  ::Chef::Log.warn('NSSM service can only be stopped on Windows platforms!')
end

action_class do
  def whyrun_supported?
    true
  end
end
