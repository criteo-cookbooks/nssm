# frozen_string_literal: true

nssm_install 'Install NSSM' do
  source node['nssm']['src']
  sha256 node['nssm']['sha256']
end
