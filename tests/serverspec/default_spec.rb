require "spec_helper"
require "serverspec"

package = "x509-certs"
service = "x509-certs"
config  = "/etc/x509-certs/x509-certs.conf"
user    = "x509-certs"
group   = "x509-certs"
ports   = [PORTS]
log_dir = "/var/log/x509-certs"
db_dir  = "/var/lib/x509-certs"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/x509-certs.conf"
  db_dir = "/var/db/x509-certs"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("x509-certs") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/x509-certs") do
    it { should be_file }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
