# frozen_string_literal: true

nssm 'bad service' do
  servicename 'service name'
  start false
  program "#{ENV['SYSTEMDRIVE']}\\Windows\\notebad.exe"
  parameters(
    AppDirectory: "#{ENV['SYSTEMDRIVE']}\\Windows",
    AppStdout: "#{ENV['SYSTEMDRIVE']}\\Windows\\notebad-svc.out",
    AppStderr: "#{ENV['SYSTEMDRIVE']}\\Windows\\notebad-svc.err",
    AppRotateFiles: 1
  )
  action :install
end

nssm 'fix service' do
  servicename 'service name'
  program "#{ENV['SYSTEMDRIVE']}\\Windows\notepad.exe"
  parameters(
    AppDirectory: "#{ENV['SYSTEMDRIVE']}\\Windows",
    AppStdout: "#{ENV['SYSTEMDRIVE']}\\Windows\\notepad-svc.out",
    AppStderr: "#{ENV['SYSTEMDRIVE']}\\Windows\\notepad-svc.err",
    AppRotateFiles: 1
  )
  action :install
end
