# NSSM Cookbook

[![Build Status](https://travis-ci.org/dhoer/chef-nssm.svg)](https://travis-ci.org/dhoer/chef-nssm)

This cookbook installs the Non-Sucking Service Manager (http://nssm.cc), and exposes resources to `install` and `remove` Windows services.
Read [TLDR](https://github.com/dhoer/chef-nssm/blob/master/TLDR.md) for more details about usage, chefspec matchers, getting help, and contributing.

## Requirements

Chef 11.14.2 and Ruby 1.9.3 or higher.

### Platform

- Windows Server 2012 R2

### Cookbooks

- windows

## Usage

Add `recipe[nssm]` to a run list.

### Examples

To install a Windows service:

    nssm 'service name' do
      program 'C:\\Windows\\System32\\java.exe'
      args '-jar C:/path/to/my-executable.jar'
      action :install
    end

To remove a Windows service:

    nssm 'service name' do
      action :remove
    end

## License

MIT - see the accompanying [LICENSE](https://github.com/dhoer/chef-nssm/blob/master/LICENSE.md) file for details.
