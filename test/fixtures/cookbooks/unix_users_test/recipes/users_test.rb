unix_users 'users' do
  action [ :remove, :create ]
  roles [ 'admin', 'webmaster' ]
end