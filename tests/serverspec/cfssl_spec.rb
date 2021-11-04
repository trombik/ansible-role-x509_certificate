require "spec_helper"
require "serverspec"

cert_dir = "/usr/local/etc"
user = "www"
group = "www"

describe file "#{cert_dir}/localhost.csr" do
  it { should exist }
  it { should be_file }
  it { should be_mode 444 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/BEGIN CERTIFICATE REQUEST/) }
end

describe file "#{cert_dir}/localhost.pem" do
  it { should exist }
  it { should be_file }
  it { should be_mode 444 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/BEGIN CERTIFICATE/) }
end

describe file "#{cert_dir}/localhost.key" do
  it { should exist }
  it { should be_file }
  it { should be_mode 440 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/BEGIN EC PRIVATE KEY/) }
end

describe file "#{cert_dir}/combined.pem" do
  it { should exist }
  it { should be_file }
  it { should be_mode 440 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/BEGIN EC PRIVATE KEY/) }
  its(:content) { should match(/BEGIN CERTIFICATE/) }
end

describe command "openssl x509 -in #{cert_dir}/localhost.pem -text" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/#{Regexp.escape("DNS:localhost, DNS:www.example.com")}/) }
  its(:stdout) { should match(/TLS Web Server Authentication/) }
  its(:stdout) { should match(/#{Regexp.escape("Subject: C = US, ST = California, L = San Francisco, O = example.com, CN = www.example.com")}/) }
end
