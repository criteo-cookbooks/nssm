provides :nssm_install
unified_mode true

property :source, kind_of: String, identity: true, name_property: true
property :sha256, kind_of: String, required: true

default_action :install

action :install do
  ::Chef::Log.warn('NSSM service can only be installed on Windows platforms!')
end

action_class do
end
