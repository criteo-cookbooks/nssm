# frozen_string_literal: true

if platform?('windows')
  src = node['nssm']['src']
  basename = src.slice(src.rindex('/') + 1, src.rindex('.') - src.rindex('/') - 1)
  system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'
  system_file = "#{Chef::Config[:file_cache_path]}/#{basename}/#{system}/nssm.exe"

  windows_zipfile 'download nssm' do
    path Chef::Config[:file_cache_path]
    source src
    overwrite true
    checksum node['nssm']['sha256']
    action :unzip
    notifies :create, 'remote_file[install nssm]', :immediately
    only_if { node['nssm']['install_nssm'] }
  end

  remote_file 'install nssm' do
    path ::NSSM.binary_path node
    source "file:///#{system_file}"
    only_if { node['nssm']['install_nssm'] }
  end
else
  Chef::Log.warn('NSSM can only be installed on Windows platforms!')
end
