# frozen_string_literal: true

name 'nssm'
maintainer 'Criteo'
maintainer_email 'systems-services-team@criteo.com'
license 'MIT'
description 'Installs/Configures NSSM'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://github.com/criteo-cookbooks/nssm'
issues_url 'https://github.com/criteo-cookbooks/nssm/issues'
version '5.0.0'

chef_version '>= 15.0'

supports 'windows'
