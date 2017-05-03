include_recipe 'java_se'

path = "#{Chef::Config[:file_cache_path]}\\selenium-server-standalone-2.53.0.jar"

remote_file path do
  source 'https://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.0.jar'
end

nssm 'service name' do
  program "#{node['java_se']['win_javalink']}\\java.exe"
  args "-jar #{path}"
  parameters(
    AppDirectory: Chef::Config[:file_cache_path],
    AppStdout: "#{Chef::Config[:file_cache_path]}\\service.log",
    AppStderr: "#{Chef::Config[:file_cache_path]}\\error.log",
    AppRotateFiles: 1
  )
  action :install
end
