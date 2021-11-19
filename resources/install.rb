provides :nssm_install, platform: 'windows'

unified_mode true

property :source, String, identity: true, name_property: true
property :sha256, String, required: true

default_action :install

action :install do
  src = new_resource.source
  basename = src.slice(src.rindex('/') + 1, src.rindex('.') - src.rindex('/') - 1)
  system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'
  download_path = "#{Chef::Config[:file_cache_path]}/#{basename}.zip"
  extract_path = "#{Chef::Config[:file_cache_path]}/nssm"
  system_file = "#{extract_path}/#{basename}/#{system}/nssm.exe"

  remote_file 'download nssm' do
    path download_path
    checksum new_resource.sha256
    source src
  end

  archive_file 'extract nssm' do
    path download_path
    destination extract_path
    overwrite :auto
  end

  remote_file 'install nssm' do
    path ::NSSM.binary_path node
    source "file:///#{system_file}"
    only_if { ::File.exist? system_file }
  end
end
