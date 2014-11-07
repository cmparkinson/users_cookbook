# Matchers for ChefSpec 3

if defined?(ChefSpec)
  def create_users(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:unix_users, :create, resource_name)
  end

  def remove_users(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:unix_users, :remove, resource_name)
  end
end
