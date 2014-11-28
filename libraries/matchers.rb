# Matchers for ChefSpec 3

if defined?(ChefSpec)
  def create_users(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:users, :create, resource_name)
  end

  def remove_users(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:users, :remove, resource_name)
  end

  def clear_password(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:users_clear_password, :run, resource_name)
  end
end
