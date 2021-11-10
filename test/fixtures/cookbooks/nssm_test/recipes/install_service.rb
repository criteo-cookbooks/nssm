# frozen_string_literal: true

include_recipe 'nssm::default'

nssm 'service name' do
  program "#{ENV['SYSTEMDRIVE']}\\Windows\\notepad.exe"
  parameters(
    AppDirectory: "#{ENV['SYSTEMDRIVE']}\\Windows",
    AppStdout: "#{ENV['SYSTEMDRIVE']}\\Windows\\notepad-svc.out",
    AppStderr: "#{ENV['SYSTEMDRIVE']}\\Windows\\notepad-svc.err",
    AppRotateFiles: 1
  )
  action :install
end
