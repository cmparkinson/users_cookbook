def whyrun_supported?
  true
end

use_inline_resources

def has_default_password?(username)
  ::File.open('/etc/shadow', 'r').each_line do |line|
    fields = line.split(':')
    return fields[1] == '!' if fields[0] == username
  end

  false
end

action :run do
  execute "clear password for #{new_resource.name}" do
    command "passwd -d #{new_resource.name} && chage -d 0 #{new_resource.name}"
    only_if { has_default_password?(new_resource.name) }
  end
end