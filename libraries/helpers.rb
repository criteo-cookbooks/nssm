# Provides some methods to ease interaction with Nssm
module Nssm
  def self.installed?(install_path)
    # check if the binary file exists - need to evaluate environment variable
    ::File.exist? binary_path(install_path).gsub(/%[^%]+%/) { |m| ENV[m[1..-2]] }
  end

  def self.binary_path(install_path)
    install_path.end_with?('.exe') ? install_path : ::File.join(install_path, 'nssm.exe')
  end
end
