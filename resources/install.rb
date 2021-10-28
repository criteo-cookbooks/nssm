provides :nssm_install, platform: 'windows'

property :source, String, identity: true, name_property: true
property :sha256, String, required: true

default_action :install

action :install do
  src = new_resource.source
  basename = src.slice(src.rindex('/') + 1, src.rindex('.') - src.rindex('/') - 1)
  download_path = "#{Chef::Config[:file_cache_path]}/#{basename}.zip"
  extract_path = "#{Chef::Config[:file_cache_path]}/#{basename}"
  system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'
  system_file = "#{extract_path}/#{basename}/#{system}/nssm.exe"

  remote_file 'download nssm' do
    checksum new_resource.sha256
    path download_path
    source src
    notifies :create, 'remote_file[install nssm]', :immediately
  end

  directory extract_path do
    action :nothing
    recursive true
    subscribes :delete, 'remote_file[download nssm]', :before
  end

  archive_file 'extract nssm' do
    action :extract
    destination extract_path
    overwrite false
    path download_path
  end

  remote_file 'install nssm' do
    path ::NSSM.binary_path node
    source "file:///#{system_file}"
    only_if { ::File.exist? system_file }
  end
end

action_class do
  def whyrun_supported?
    true
  end
end
