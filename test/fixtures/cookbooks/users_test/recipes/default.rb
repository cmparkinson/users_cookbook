users 'users' do
  action [ :remove, :create ]
  roles [ 'admin', 'webmaster' ]
  clear_password true
end