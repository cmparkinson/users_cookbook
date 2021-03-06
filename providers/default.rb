use_inline_resources

require 'etc'

def whyrun_supported?
  true
end

def chef_solo_search_installed?
  ::Search::const_get('Helper').is_a?(Class)
rescue NameError
  false
end

def users_to_add
  roles = new_resource.roles
  users = Array.new

  return data_bag(new_resource.user_data_bag) unless roles

  roles.each do |r|
    role_item = data_bag_item(new_resource.roles_data_bag, r)
    fail "Item #{r} does not exist in role data bag #{new_resource.roles_data_bag}" unless role_item
    
    users |= role_item['users']
  end

  users
end

def user_exists?(user)
  begin
    Etc.getpwnam(user)
    true
  rescue ArgumentError
    false
  end
end

def existing_managed_users
  users = Array.new
  
  # Get a list of all the users on the system
  Etc.passwd {|u| users << u.name }

  # Intersect the existing users with the data bag containing all users
  users & data_bag(new_resource.user_data_bag)
end

action :create do
  if Chef::Config[:solo] and not chef_solo_search_installed?
    Chef::Log.warn("This recipe uses data bag searches.  Chef Solo doesn't support searching unless the chef-solo-search cookbook is installed.")
  else
    # Iterate through the list of users that should exist on this node
    users_to_add.each do |username|
      u = data_bag_item(new_resource.user_data_bag, username)
      
      # Create the user's group if it doesn't already exist, otherwise the user creation block will fail
      
      group u['id'] do
        gid u['gid']
        only_if { u['gid'] and u['gid'].kind_of?(Numeric) }
      end

      # Set home_basedir based on platform_family
      case node['platform_family']
      when 'mac_os_x'
        home_basedir = '/Users'
      when 'debian', 'rhel', 'fedora', 'arch', 'suse', 'freebsd'
        home_basedir = '/home'
      end

      if u['home']
        home_dir = u['home']
      else
        home_dir = "#{home_basedir}/#{u['id']}"
      end      

      ssh_keys_present = u['ssh_keys'].is_a?(Array) && u['ssh_keys'].count > 0
      user_exists = user_exists?(u['id'])

      # Create a resource to clear the user's password if SSH keys are present and the user doesn't already exist.
      # It will only be run if the user is created.
      users_clear_password u['id'] do
        action :nothing
      end

      user u['id'] do
        action :create
        supports :manage_home => true

        uid u['uid'] if u['uid']
        gid u['gid'] if u['gid']
        shell u['shell']
        comment u['comment']

        home home_dir

        # Clear the new user's password
        notifies :run, "users_clear_password[#{u['id']}]" if new_resource.clear_password && ssh_keys_present && !user_exists
      end

      # Create and manage the authorized_keys file
      if u['ssh_keys']
        directory "#{home_dir}/.ssh" do
          owner u['id']
          group u['gid'] || u['id']
          mode '0700'
        end

        template "#{home_dir}/.ssh/authorized_keys" do
          source 'authorized_keys.erb'
          cookbook new_resource.cookbook
          owner u['id']
          mode '0600'
          variables :ssh_keys => u['ssh_keys']
        end
      end
    end
  end
end

action :remove do
  if Chef::Config[:solo] and not chef_solo_search_installed?
    Chef::Log.warn("This recipe uses data bag searches.  Chef Solo doesn't support searching unless the chef-solo-search cookbook is installed.")
  else

    # Start with the easy users; the ones that are tagged for removal
    search(new_resource.user_data_bag, 'remove:true').each do |u|
      user u['id'] do
        action :remove
      end
    end

    # Remove any managed users that shouldn't be on this node

    # Start with a list of managed users on the node
    users = existing_managed_users

    # Subtract the users that are supposed to be on the node
    users -= users_to_add

    # Remove the users still in the array from the node
    users.each do |u|
      user u do
        action :remove
      end
    end
  end
end
