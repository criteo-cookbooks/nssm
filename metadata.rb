name 'nssm'
maintainer 'Dennis Hoer'
maintainer_email 'dennis.hoer@gmail.com'
license 'MIT'
description 'Installs/Configures NSSM'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.2.1'

supports 'windows'

depends 'windows', '~> 1.0'

source_url 'https://github.com/dhoer/chef-nssm' if respond_to?(:source_url)
issues_url 'https://github.com/dhoer/chef-nssm/issues' if respond_to?(:issues_url)
