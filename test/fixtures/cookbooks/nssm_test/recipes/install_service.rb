nssm 'service name' do
  program 'C:\\Windows\\System32\\java.exe'
  args '-jar C:/path/to/my-executable.jar'
  params(
    AppDirectory: 'C:/path/to',
    AppStdout: 'C:/path/to/log/service.log',
    AppStderr: 'C:/path/to/log/error.log',
    AppRotateFiles: 1
  )
  action :install
end
