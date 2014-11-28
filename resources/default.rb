actions :create, :remove
default_action :create

attribute :user_data_bag, :kind_of => String, :name_attribute => true
attribute :roles_data_bag, :kind_of => String, :default => 'user_roles'
attribute :roles, :kind_of => Array
attribute :clear_password, :kind_of => [TrueClass, FalseClass], :default => false
attribute :cookbook, :kind_of => String, :default => 'users'
