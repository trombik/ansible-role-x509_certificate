require "spec_helper"
require "serverspec"

package = "openssl"
user = "www-data"
group = "www-data"
default_user = "root"
default_group = "root"
additional_packages = ["quagga"]
additional_user = "quagga"
additional_group = "quagga"
prefix = ""
syslog_file = case os[:family]
              when "freebsd", "openbsd", "redhat", "fedora"
                "/var/log/messages"
              else
                "/var/log/syslog"
              end

case os[:family]
when "redhat", "fedora"
  user = "ftp"
  group = "ftp"
when "openbsd"
  user = "www"
  group = "www"
  default_group = "wheel"
  additional_user = "_quagga"
  additional_group = "_quagga"
when "freebsd"
  user = "www"
  group = "www"
  default_group = "wheel"
  prefix = "/usr/local"
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

user(additional_user) do
  it { should exist }
end

group(additional_group) do
  it { should exist }
end

describe file("#{prefix}/etc/ssl/foo.pem") do
  it { should exist }
  it { should be_file }
  it { should be_mode 444 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
end

describe command("openssl x509 -noout -in #{prefix}/etc/ssl/foo.pem") do
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

describe command("openssl rsa -check -noout -in /usr/local/etc/ssl/bar/bar.key") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^RSA key ok$/) }
end

describe file("#{prefix}/etc/quagga/certs/quagga.pem") do
  it { should exist }
  it { should be_file }
  it { should be_mode 444 }
  it { should be_owned_by additional_user }
  it { should be_grouped_into additional_group }
end

describe command("openssl x509 -noout -in #{prefix}/etc/quagga/certs/quagga.pem") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should eq "" }
end

describe file("#{prefix}/etc/quagga/certs/quagga.key") do
  it { should exist }
  it { should be_file }
  it { should be_mode 440 }
  it { should be_owned_by additional_user }
  it { should be_grouped_into additional_group }
end

describe command("openssl rsa -check -noout -in #{prefix}/etc/quagga/certs/quagga.key") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^RSA key ok$/) }
end

describe file("#{prefix}/etc/quagga/certs/pkcs8.key") do
  it { should exist }
  it { should be_file }
  it { should be_mode 440 }
  it { should be_owned_by additional_user }
  it { should be_grouped_into additional_group }
end

describe command("openssl pkcs8 -inform pem -outform pem -nocrypt -in #{prefix}/etc/quagga/certs/pkcs8.key") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/BEGIN PRIVATE KEY/) }
end

%w[foo bar buz foobar].each do |k|
  describe command("grep '#{k} is notified' #{syslog_file}") do
    its(:exit_status) { should eq 0 }
  end
end
