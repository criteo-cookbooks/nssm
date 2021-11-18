# frozen_string_literal: true

nssm 'service name' do
  program "#{ENV['SYSTEMDRIVE']}\\Windows\notepad.exe"
  action :remove
end
