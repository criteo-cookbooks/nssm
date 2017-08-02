# NSSM CHANGELOG

## 4.0.0 2017-08-02

- Convert default recipe to custom resource with idempotence 
- Allow install of nssm to be optional
- Properly escape parameters in install action (custom quoting should be removed)
- Make start service idempotent
- Unstable version of nssm is used to ensure proper idempotency. Without it, the `load_current_value` would fail to get every setting.

## 3.0.2 2017-07-13

- Fix whyrun issues

## 3.0.1 2017-07-07

- Chef 12.7 or higher is now required
- Fix parameters attribute

## 3.0.0 2017-03-24

- Rename params attribute to parameters to be Chef 13 compatible

## 2.0.0 2016-10-03

- Drop support for Chef 11

## 1.2.1 2016-04-12

- Include default recipe in provide only if required

## 1.2.0 2015-08-09

- Use new install_location attribute everywhere
- Don't try to install nssm if it's already there

## 1.1.0 2015-02-06

- Add an attribute for the install location of nssm.exe

## 1.0.0 2014-12-17

- Remove deprecated matchers
- Ensure nssm is being installed before service is installed

## 0.2.0 2014-10-08

- Chef cache path no longer hard coded
- Chefspec matchers comply with naming convention

## 0.1.0 2014-09-21

- Initial release using nssm v2.24
