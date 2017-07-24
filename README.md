# NSSM Cookbook

[![Cookbook Version](http://img.shields.io/cookbook/v/nssm.svg?style=flat-square)][cookbook]
[![Build Status](https://img.shields.io/appveyor/ci/dhoer/chef-nssm/master.svg?style=flat-square)][win]

[cookbook]: https://supermarket.chef.io/cookbooks/nssm
[win]: https://ci.appveyor.com/project/dhoer/chef-nssm

This cookbook installs the Non-Sucking Service Manager (http://nssm.cc), and exposes resources to `install`
and `remove` Windows services.

## Requirements

- Chef 12.7+

### Platform

- Windows

## Usage

Add `recipe[nssm]` to run list.

### Quick Start

To install a Windows service:

```ruby
nssm 'service name' do
  program 'C:\Windows\System32\java.exe'
  args '-jar C:/path/to/my-executable.jar'
  action :install
end
```

To remove a Windows service:

```ruby
nssm 'service name' do
  action :remove
end
```

### Using Parameters

A parameter is a hash key representing the same name as the registry entry which controls the associated functionality.
So, for example, the following sets the Startup directory, I/O redirection, and File rotation for a service:

```ruby
nssm 'service name' do
  program 'C:\Windows\System32\java.exe'
  args '-jar C:/path/to/my-executable.jar'
  parameters(
    AppDirectory: 'C:/path/to',
    AppStdout: 'C:/path/to/log/service.log',
    AppStderr: 'C:/path/to/log/error.log',
    AppRotateFiles: 1
  )
  action %i[install start]
end
```

### Attributes

- `node['nssm']['src']` - This can either be a URI or a local path to nssm zip.
- `node['nssm']['sha256']` - SHA-256 checksum of the file. Chef will not download it if the local file matches the
checksum.

### Resource/Provider

#### Actions

- `install` - Install a Windows service, and update it accordingly. (Note: it will NOT automatically restart the service, make sure to notify the according service to restart)
- `install_if_missing` - Install a Windows service, but do not update it if present (old behaviour)
- `remove` - Remove Windows service.
- `start` - Start the Windows service.
- `stop` - Stop the Windows service.

#### Attribute Parameters

- `servicename` - Name attribute. The name of the Windows service.
- `program` - The program to be run as a service.
- `args` - String of arguments for the program. Optional
- `parameters` - Hash of key value pairs where key represents associated registry entry. Optional
- `start` - Start service after installing. Default -  true
- `nssm_binary` - Path to nssm binary. Default - `node['nssm']['install_location']\nssm.exe`

## ChefSpec Matchers

The NSSM cookbook includes custom [ChefSpec](https://github.com/sethvargo/chefspec) matchers you can use to test your
own cookbooks that consume Windows cookbook LWRPs.

Example Matcher Usage

```ruby
expect(chef_run).to install_nssm('service name').with(
  :program 'C:\Windows\System32\java.exe'
  :args '-jar C:/path/to/my-executable.jar'
)
```

NSSM Cookbook Matchers

- install_nssm(servicename)
- remove_nssm(servicename)

## Getting Help

- Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/nssm).
- Report bugs and discuss potential features in [Github issues](https://github.com/dhoer/chef-nssm/issues).

## Contributing

Please refer to [CONTRIBUTING](https://github.com/dhoer/chef-nssm/blob/master/CONTRIBUTING.md).

## License

MIT - see the accompanying [LICENSE](https://github.com/dhoer/chef-nssm/blob/master/LICENSE.md) file for details.
