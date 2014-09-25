nssm 'service name' do
  program 'C:\\Windows\\System32\\java.exe'
  args '-jar C:/path/to/my-executable.jar'
  action :install
end
