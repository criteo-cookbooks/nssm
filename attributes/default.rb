# frozen_string_literal: true

default['nssm']['src'] = 'https://nssm.cc/ci/nssm-2.24-94-g9c88bc1.zip'
default['nssm']['sha256'] = '0bbe25025b69ebd8ab263ec4b443513d28a0d072e5fdd9b5cdb327359a27f96e'

default['nssm']['install_location'] = ENV['WINDIR']
default['nssm']['install_nssm'] = true
