provides :nssm_install

property :source, identity: true, name_attribute: true
property :sha256, kind_of: String, required: true

default_action :install

action :install do
  ::Chef::Log.warn('NSSM service can only be installed on Windows platforms!')
end

action_class do
  def whyrun_supported?
    true
  end
end
