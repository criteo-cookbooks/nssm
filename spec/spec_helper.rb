# frozen_string_literal: true

# Added by ChefSpec
require 'chefspec'
require 'chefspec/berkshelf'

CACHE = Chef::Config[:file_cache_path]
VERSION = '2.24-94-g9c88bc1'.freeze

ChefSpec::Coverage.start!
