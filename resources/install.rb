provides :nssm_install, platform: 'windows'
unified_mode true

property :source, kind_of: String, identity: true, name_property: true
property :sha256, kind_of: String, required: true

default_action :install

action :install do
  src = new_resource.source
  basename = src.slice(src.rindex('/') + 1, src.rindex('.') - src.rindex('/') - 1)
  system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'
  system_file = "#{Chef::Config[:file_cache_path]}/nssm/#{basename}/#{system}/nssm.exe"
  old_extract = "#{Chef::Config[:file_cache_path]}/#{basename}"

  directory old_extract do
    action :delete
    recursive true
  end if Dir.exist?(old_extract)

  remote_file "#{Chef::Config[:file_cache_path]}/#{basename}.zip" do
    source src
    checksum new_resource.sha256
  end

  archive_file "#{Chef::Config[:file_cache_path]}/#{basename}.zip" do
    destination "#{Chef::Config[:file_cache_path]}/nssm"
    overwrite :auto
  end

  remote_file 'install nssm' do
    path ::NSSM.binary_path node
    source "file:///#{system_file}"
  end
end

action_class do
end
