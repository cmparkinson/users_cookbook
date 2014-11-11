require 'spec_helper'

context 'admin1' do
  describe user('admin1') do
    it { should exist }
  end

  describe file('/home/admin1/.ssh') do
    it { should be_directory }
    it { should be_mode 700 }
    it { should be_owned_by 'admin1' }
  end

  describe file('/home/admin1/.ssh/authorized_keys') do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'admin1' }
    its(:content) { should match /\s*KEY1/ }
    its(:content) { should match /\s*KEY2/ }
  end

  context 'Password should be cleared' do
    describe file('/etc/shadow') do
      its(:content) { should match /^admin1::0:0:99999:7:::/ }
    end
  end
end

context 'admin2' do
  describe user('admin2') do
    it { should exist }
  end

  describe file('/home/admin2/.ssh') do
    it { should_not be_file }
    it { should_not be_directory }
  end

  context 'Password should not be cleared' do
    describe file('/etc/shadow') do
      its(:content) { should match /^admin2:!:[0-9]+:0:99999:7:::/ }
    end
  end
end

describe user('www-data') do
  it { should_not exist }
end