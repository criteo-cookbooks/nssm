if defined?(ChefSpec)
  def install_nssm(servicename)
    ChefSpec::Matchers::ResourceMatcher.new(:nssm, :install, servicename)
  end

  def remove_nssm(servicename)
    ChefSpec::Matchers::ResourceMatcher.new(:nssm, :remove, servicename)
  end

  # deprecated: use install_nssm
  def install_nssm_service(servicename)
    ChefSpec::Matchers::ResourceMatcher.new(:nssm, :install, servicename)
  end

  # deprecated: use remove_nssm
  def remove_nssm_service(servicename)
    ChefSpec::Matchers::ResourceMatcher.new(:nssm, :remove, servicename)
  end
end
