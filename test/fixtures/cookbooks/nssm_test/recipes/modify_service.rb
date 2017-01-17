include_recipe 'java_se'

jar_path = ::File.join(Chef::Config[:file_cache_path], "selenium-server-standalone-2.53.0.jar")

remote_file jar_path do
  source 'https://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.0.jar'
end

nssm 'bad service' do
  servicename 'service name'
  start false
  program "#{node['java_se']['win_javalink']}\\javabad.exe"
  args %(-jar """#{jar_path.gsub('/', '\\')}bad""")
  params(
    AppDirectory: ::File.join(Chef::Config[:file_cache_path], 'bad').gsub('/', '\\'),
    AppStdout: ::File.join(Chef::Config[:file_cache_path],"bad.stdout.log").gsub('/', '\\'),
    AppStderr: ::File.join(Chef::Config[:file_cache_path],"bad.error.log").gsub('/', '\\'),
    AppRotateFiles: 2
  )
  action :install
end

nssm 'fix service' do
  servicename 'service name'
  program "#{node['java_se']['win_javalink']}\\java.exe"
  args %(-jar """#{jar_path.gsub('/', '\\')}""")
  params(
    AppDirectory: Chef::Config[:file_cache_path].gsub('/', '\\'),
    AppStdout: ::File.join(Chef::Config[:file_cache_path],"service.log").gsub('/', '\\'),
    AppStderr: ::File.join(Chef::Config[:file_cache_path],"error.log").gsub('/', '\\'),
    AppRotateFiles: 1
  )
  action :install
end
