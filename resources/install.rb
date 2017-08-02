provides :nssm_install, platform: 'windows'

property :source, identity: true, name_attribute: true
property :sha256, kind_of: String, required: true

default_action :install

action :install do
  src = new_resource.source
  basename = src.slice(src.rindex('/') + 1, src.rindex('.') - src.rindex('/') - 1)
  system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'
  system_file = "#{Chef::Config[:file_cache_path]}/#{basename}/#{system}/nssm.exe"

  windows_zipfile 'download nssm' do
    path Chef::Config[:file_cache_path]
    source src
    overwrite true
    checksum new_resource.sha256
    action :unzip
    notifies :create, 'remote_file[install nssm]', :immediately
    not_if { Digest::SHA256.file("#{Chef::Config[:file_cache_path]}/#{basename}.zip").hexdigest == new_resource.sha256 } if ::File.exist?("#{Chef::Config[:file_cache_path]}/#{basename}.zip")
  end

  remote_file 'install nssm' do
    path ::NSSM.binary_path node
    source "file:///#{system_file}"
  end
end

action_class do
  def whyrun_supported?
    true
  end
end
