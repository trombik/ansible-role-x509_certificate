require "spec_helper"
require "serverspec"

package = "openssl"
user = ""
group = ""
default_user = "root"
default_group = "root"
additional_packages = ["postfix"]
additional_users = ["postfix"]
additional_groups = ["mail"]

case os[:family]
when "freebsd"
  user = "www"
  group = "www"
  default_group = "wheel"
end

if os[:family] !~ /bsd$/
  describe package(package) do
    it { should be_installed }
  end
end

additional_packages.each do |p|
  package(p) do
    it { should be_installed }
  end
end

additional_users.each do |u|
  user(u) do
    it { should exist }
  end
end

additional_groups.each do |g|
  group(g) do
    it { should exist }
  end
end

describe file("/usr/local/etc/ssl/foo.pem") do
  it { should exist }
  it { should be_file }
  it { should be_mode 444 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
end

describe command("openssl x509 -noout -in /usr/local/etc/ssl/foo.pem") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should eq "" }
end

describe file("/usr/local/etc/ssl/bar/bar.pub") do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe command("openssl x509 -noout -in /usr/local/etc/ssl/bar/bar.pub") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should eq "" }
end

describe file("/usr/local/etc/ssl/bar/bar.key") do
  it { should exist }
  it { should be_file }
  it { should be_mode 400 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe command("sudo openssl rsa -check -noout -in /usr/local/etc/ssl/bar/bar.key") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^RSA key ok$/) }
end

describe file("/usr/local/etc/postfix/certs/postfix.pem") do
  it { should exist }
  it { should be_file }
  it { should be_mode 444 }
  it { should be_owned_by "postfix" }
  it { should be_grouped_into "mail" }
end

describe command("openssl x509 -noout -in /usr/local/etc/postfix/certs/postfix.pem") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should eq "" }
end

describe file("/usr/local/etc/postfix/certs/postfix.key") do
  it { should exist }
  it { should be_file }
  it { should be_mode 440 }
  it { should be_owned_by "postfix" }
  it { should be_grouped_into "mail" }
end

describe command("sudo openssl rsa -check -noout -in /usr/local/etc/postfix/certs/postfix.key") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^RSA key ok$/) }
end
