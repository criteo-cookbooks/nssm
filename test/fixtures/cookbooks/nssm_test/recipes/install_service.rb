include_recipe 'java'

path = "#{Chef::Config[:file_cache_path]}\\selenium-server-standalone-2.47.1.jar"

remote_file path do
  source 'http://selenium-release.storage.googleapis.com/2.47/selenium-server-standalone-2.47.1.jar'
end

nssm 'service name' do
  program 'C:\Program Files (x86)\Java\jdk1.8.0_51\bin\java.exe'
  args "-jar #{path}"
  params(
    AppDirectory: Chef::Config[:file_cache_path],
    AppStdout: "#{Chef::Config[:file_cache_path]}\\service.log",
    AppStderr: "#{Chef::Config[:file_cache_path]}\\error.log",
    AppRotateFiles: 1
  )
  action :install
end
