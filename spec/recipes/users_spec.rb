require 'spec_helper'

def get_passwd_user(user, list)
  list.each do |u|
    return u if user == u.name
  end

  raise ArgumentError
end

describe 'unix_users_test::users_test' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new(
        step_into: ['unix_users'],
        platform: 'ubuntu',
        version: '12.04'
      ) do |node, server|
      server.create_data_bag('users', {
        'adminuser1' => {
          id: 'adminuser1',
          uid: 1000,
          ssh_keys: ['AABBCCDDEEFF', 'GGHHIIJJKKLL']
        },
        'adminuser2' => {
          id: 'adminuser2',
          uid: 2000
        },
        'nocreate1' => {
          id: 'nocreate1',
          uid: 1001,
          ssh_keys: ['AABBCCDDEEFF']
        },
        'nocreate2' => {
          id: 'nocreate2',
          uid: 3
        },
        'webmaster1' => {
          id: 'webmaster1',
          uid: 4000
        },
        'remove1' => {
          id: 'remove1',
          remove: true
        },
        'usernotinrole' => {
          id: 'usernotinrole'
        },
        'existinguser1' => {
          id: 'existinguser1',
          ssh_keys: ['AABBCC']
        }
      })

      server.create_data_bag('unix_user_roles', {
        'admin' => {
          id: 'admin',
          users: [ 'adminuser1', 'adminuser2' ]
        },
        'webmaster' => {
          id: 'webmaster',
          users: [ 'webmaster1', 'existinguser1' ]
        },
        'unusedrole' => {
          id: 'unusedrole',
          users: [ 'nocreate2' ]
        }
      })
    end.converge(described_recipe)
  end

  # Create a list of /etc/passwd users
  let(:passwd_users) do
    users = [ 'root', 'user1', 'user2', 'usernotinrole', 'existinguser1' ]
    mock_passwd = Struct.new(:name)
    passwd = []

    users.each { |u| passwd << mock_passwd.new(u) }

    passwd
  end

  # Stub the Etc.passwd and Etc.getpwnam calls made by the provider
  before do
    allow(Etc).to receive(:passwd) do |&block|
      passwd_users.each { |u| block.call(u) }
    end

    allow(Etc).to receive(:getpwnam) do |u|
      get_passwd_user(u, passwd_users)
    end
  end

  context 'Resource "unix_users"' do
    it 'manages users from the "users" data bag' do
      expect(chef_run).to create_users('users')
      expect(chef_run).to remove_users('users')
    end

    it 'creates user "adminuser1"' do
      expect(chef_run).to create_user('adminuser1')
      expect(chef_run).to create_directory('/home/adminuser1/.ssh').with(
        user: 'adminuser1',
        mode: '0700'
      )
      expect(chef_run).to create_template('/home/adminuser1/.ssh/authorized_keys').with(
        user: 'adminuser1',
        mode: '0600'
      )
    end

    it 'does not create user "nocreate1"' do
      expect(chef_run).to_not create_user('nocreate1')
      expect(chef_run).to_not create_directory('/home/nocreate1/.ssh')
    end

    it 'does not create user "nocreate2"' do
      expect(chef_run).to_not create_user('nocreate2')
    end

    it 'does not create ".ssh" directory for adminuser2' do
      expect(chef_run).to create_user('adminuser2')
      expect(chef_run).to_not create_directory('/home/adminuser2/.ssh')
    end

    it 'does create user "webmaster1"' do
      expect(chef_run).to create_user('webmaster1')
    end

    it 'removes user "remove1"' do
      expect(chef_run).to remove_user('remove1')
    end

    it 'removes user "usernotinrole"' do
      expect(chef_run).to remove_user('usernotinrole')
    end

    it 'creates an authorized_keys file' do
      expect(chef_run).to render_file('/home/adminuser1/.ssh/authorized_keys')
        .with_content("AABBCCDDEEFF\nGGHHIIJJKKLL")
    end

    it 'clears passwords for new users with SSH keys' do
      resource = chef_run.user('adminuser1')
      expect(resource).to notify('unix_users_clear_password[adminuser1]')
      
      resource = chef_run.user('adminuser2')
      expect(resource).to_not notify('unix_users_clear_password[adminuser2]')
    end

    it 'does not clear passwords for existing users' do
      resource = chef_run.user('existinguser1')
      expect(resource).not_to notify('unix_users_clear_password[existinguser1]')
    end
  end
end
