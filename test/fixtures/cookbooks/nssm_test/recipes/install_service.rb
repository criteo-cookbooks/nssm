# frozen_string_literal: true

include_recipe 'java_se'
include_recipe 'nssm::default'

jar_path = ::File.join(Chef::Config[:file_cache_path], 'selenium-server-standalone-2.53.0.jar')

remote_file jar_path do
  source 'https://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.0.jar'
end

nssm 'service name' do
  program "#{node['java_se']['win_javalink']}\\java.exe"
  args %(-jar #{jar_path.tr('/', '\\')})
  parameters(
    AppDirectory: Chef::Config[:file_cache_path].tr('/', '\\'),
    AppStdout: "#{Chef::Config[:file_cache_path]}\\service.log".tr('/', '\\'),
    AppStderr: "#{Chef::Config[:file_cache_path]}\\error.log".tr('/', '\\'),
    AppRotateFiles: 1
  )
  action :install
end
