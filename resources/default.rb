actions :install, :remove
default_action :install

attribute :servicename, name_attribute: true
attribute :app,    kind_of: String, required: true
attribute :args,   kind_of: Array, default: []
attribute :start,  kind_of: [TrueClass, FalseClass], default: true
