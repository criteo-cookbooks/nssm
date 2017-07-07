# frozen_string_literal: true

name 'nssm_test'
maintainer 'Dennis Hoer'
maintainer_email 'dennis.hoer@gmail.com'
license 'All rights reserved'
description 'Installs/Configures nssm_test'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'nssm'
depends 'java_se', '~> 8.0'
