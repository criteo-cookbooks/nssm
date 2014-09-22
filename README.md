# NSSM Cookbook

[![Build Status](https://travis-ci.org/dhoer/chef-nssm.svg)](https://travis-ci.org/dhoer/chef-nssm)

This cookbook installs the Non-Sucking Service Manager (http://nssm.cc), and exposes resources to `install` and `remove` Windows services.
Read [TLDR](https://github.com/dhoer/chef-nssm/blob/master/TLDR.md) for more details about usage, chefspec matchers, getting help and contributing.

## Requirements

### Platform

Should work under Windows 2000 or later.  

### Cookbooks

- windows

## Usage

Simply add `recipe[nssm]` to a run list.

### Examples

To install a Windows service:

    nssm 'service name' do
      app 'java'
      args [
        '-jar',
        "'C:\\path to\\my-executable.jar'"
      ]
      action :install
    end

To remove a Windows service:

    nssm 'service name' do
      action :remove
    end

## License

MIT - see the accompanying [LICENSE](https://github.com/dhoer/chef-nssm/blob/master/LICENSE.md) file for details.
