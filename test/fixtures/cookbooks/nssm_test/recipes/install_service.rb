include_recipe 'java_se'
include_recipe "nssm::default"

jar_path = ::File.join(Chef::Config[:file_cache_path], "selenium-server-standalone-2.53.0.jar")

remote_file jar_path do
  source 'https://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.0.jar'
end

nssm 'service name' do
  program "#{node['java_se']['win_javalink']}\\java.exe"
  args %(-jar "#{jar_path.gsub('/', '\\')}")
  params(
    AppDirectory: Chef::Config[:file_cache_path].gsub('/', '\\'),
    AppStdout: ::File.join(Chef::Config[:file_cache_path],"service.log").gsub('/', '\\'),
    AppStderr: ::File.join(Chef::Config[:file_cache_path],"error.log").gsub('/', '\\'),
    AppRotateFiles: 1
  )
  action :install

  notifies :run, 'ruby_block[notified]'
end

ruby_block "notified" do
  block do
  end

  action :nothing
end
