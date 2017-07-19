provides :nssm_service
provides :nssm # TODO: migrate to nssm_service with a breaking change notice

property :servicename, identity: true, name_attribute: true
property :program, kind_of: String, required: true
property :args, kind_of: String
property :parameters, kind_of: Hash, default: lazy { ::Mash.new }
property :nssm_binary, kind_of: String, default: nil
# TODO: remove this
property :start, kind_of: [TrueClass, FalseClass], default: true

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
