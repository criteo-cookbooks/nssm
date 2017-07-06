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
  end

  remote_file 'install nssm' do
    path "#{node['nssm']['install_location']}/nssm.exe"
    source "file:///#{system_file}"
  end
else
  log('NSSM can only be installed on Windows platforms!') { level :warn }
end
