# frozen_string_literal: true

name 'nssm'
maintainer 'Dennis Hoer'
maintainer_email 'dennis.hoer@gmail.com'
license 'MIT'
description 'Installs/Configures NSSM'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://github.com/criteo-cookbooks/nssm'
issues_url 'https://github.com/criteo-cookbooks/nssm/issues'
version '4.0.1'

chef_version '>= 12.7'

supports 'windows'
depends 'windows'
