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

- install_nssm_service(servicename)
- remove_nssm_service(servicename)

## Getting Help

- Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/chef-nssm).
- Report bugs and discuss potential features in [Github issues](https://github.com/dhoer/chef-nssm/issues).

## Contributing

Please refer to [CONTRIBUTING](https://github.com/dhoer/chef-nssm/blob/master/CONTRIBUTING.md).
