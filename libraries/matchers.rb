if defined?(ChefSpec)
  def install_nssm_service(servicename)
    ChefSpec::Matchers::ResourceMatcher.new(:nssm, :install, servicename)
  end

  def remove_nssm_service(servicename)
    ChefSpec::Matchers::ResourceMatcher.new(:nssm, :remove, servicename)
  end
end
