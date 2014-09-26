# TL;DR

## Usage

Advanced usage of NSSM.

### Arguments with Spaces

Having spaces in `servicename` and `program` attributes is not a problem, but spaces in an argument is a different matter.

When dealing with an argument containing spaces, add [3 double quotes](https://stackoverflow.com/questions/7760545/cmd-escape-double-quotes-in-parameter/15262019#15262019?s=62228804c3f84fceb873ee30dd784161) `"""` around it:

    nssm 'service name' do
      program 'C:\Program Files\Java\jdk1.7.0_67\bin\java.exe'
      args '-jar """C:/path/with spaces to/my-executable.jar"""'
      action :install
    end
    
When dealing with arguments requiring [interpolation](http://en.wikibooks.org/wiki/Ruby_Programming/Syntax/Literals#Interpolation) and contain an argument with spaces, then encapsulate `args` using `%{}` notation and use `"""` around arguments with spaces:

    my_path_with_spaces = 'C:/path/with spaces to/my-executable.jar'
    nssm 'service name' do
      program 'C:\Program Files\Java\jdk1.7.0_67\bin\java.exe'
      args %{-jar """#{my_path_with_spaces}"""}
      action :install
    end

### Attributes

- `node['nssm']['src']` - This can either be a URI or a local path to nssm zip.
- `node['nssm']['sha256']` - SHA-256 checksum of the file. Chef will not download it if the local file matches the checksum.

### Resource/Provider

#### Actions

- :install: Install a Windows service.
- :remove: Remove Windows service.

#### Attribute Parameters

- :servicename: Name attribute. The name of the Windows service.
- :program: The program to be run as a service. 
- :args: String of arguments for the program. Optional
- :start: Start service after installing. Default: true

## ChefSpec Matchers

The NSSM cookbook includes custom [ChefSpec](https://github.com/sethvargo/chefspec) matchers you can use to test your own cookbooks that consume Windows cookbook LWRPs.

Example Matcher Usage

    expect(chef_run).to install_nssm_service('service name').with(
      :program 'C:\\Windows\\System32\\java.exe'
      :args '-jar C:/path/to/my-executable.jar'    
    )
      
NSSM Cookbook Matchers

- install_nssm_service(servicename)
- remove_nssm_service(servicename)

## Getting Help

- Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/chef-nssm).
- Report bugs and discuss potential features in [Github issues](https://github.com/dhoer/chef-nssm/issues).

## Contributing

Please refer to [CONTRIBUTING](https://github.com/dhoer/chef-nssm/blob/master/CONTRIBUTING.md).
