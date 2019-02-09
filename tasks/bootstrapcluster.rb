#!/opt/puppetlabs/puppet/bin/ruby

# @see https://mariadb.com/kb/en/library/getting-started-with-mariadb-galera-cluster/#bootstrapping-a-new-cluster
require 'json'
require 'open3'
require 'puppet'

def bootstrapcluster()
  if service_name.nil?
    stdout, _stderr, _status = Open3.capture3('facter', '-p', 'os.family')
    osfamily = stdout.strip
    stdout, _stderr, _status = Open3.capture3('facter', '-p', 'os.release.version')
    osversion = stdout.strip
    cmd_string =  if osfamily == 'RedHat' and osversion == '6'
                     'service mysql bootstrap'
                  else
                     'galera_new_cluster'
                  end
  end
  _stdout, stderr, status = Open3.capture3(cmd_string)
  raise Puppet::Error, stderr if status != 0
  { status: "Cluster bootstrap successful" }
end

begin
  result = bootstrapcluster()
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end