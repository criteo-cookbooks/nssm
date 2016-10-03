if platform?('windows')
  src = node['nssm']['src']
  basename = src.slice(src.rindex('/') + 1, src.rindex('.') - src.rindex('/') - 1)
  cache_path = "#{Chef::Config[:file_cache_path]}/#{basename}.zip"

  remote_file "download #{cache_path}" do
    path cache_path
    source src
    checksum node['nssm']['sha256']
    notifies :run, "powershell_script[unzip #{cache_path}]", :immediately
  end

  powershell_script "unzip #{cache_path}" do
    code "Add-Type -A 'System.IO.Compression.FileSystem';" \
      " [IO.Compression.ZipFile]::ExtractToDirectory('#{cache_path}', '#{Chef::Config[:file_cache_path]}');"
    action :nothing
    notifies :run, 'batch[install nssm]', :immediately
  end

  system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'
  system_file = "#{Chef::Config[:file_cache_path].tr('/', '\\')}\\#{basename}\\#{system}\\nssm.exe"

  batch 'install nssm' do
    code "xcopy \"#{system_file}\" \"#{node['nssm']['install_location']}\" /y"
    action :nothing
  end
else
  log('NSSM can only be installed on Windows platforms!') { level :warn }
end
