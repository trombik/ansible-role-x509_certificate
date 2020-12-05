require "spec_helper"
require "serverspec"

files = %w{remove_me.pem remove_me.key}

describe file "/tmp/ansible_test.done" do
  it { should exist }
  it { should be_file }
end

files.each do |f|
  describe file "/usr/local/etc/ssl/#{f}" do
    it { should_not exist }
  end
end
