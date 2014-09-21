nssm 'service name' do
  app 'java'
  args [
    '-jar',
    "'C:\\path to\\my-executable.jar'"
  ]
  action :install
end
