# TL;DR

## Usage

### Attributes

- `node['nssm']['src']` - This can either be a URI or a local path to nssm zip.
- `node['nssm']['sha256']` - SHA-256 checksum of the file. Chef will not download it if the local file matches the checksum.

### Resource/Provider

#### Actions

- :install: Install a Windows service.
- :remove: Remove Windows service.

#### Attribute Parameters

- :servicename: Name attribute. The name of the Windows service.
- :app: The program to be run as a service. 
- :args: Array of arguments for the program. Optional
- :start: Start service after installing. Default: true

## ChefSpec Matchers

The NSSM cookbook includes custom [ChefSpec](https://github.com/sethvargo/chefspec) matchers you can use to test your own cookbooks that consume Windows cookbook LWRPs.

Example Matcher Usage

    expect(chef_run).to install_nssm_service('service name').with(
      app: 'java')
      
NSSM Cookbook Matchers

- install_nssm_service
- remove_nssm_service

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github
