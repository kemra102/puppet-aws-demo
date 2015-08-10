#!/usr/bin/env bash

# Update OS
yum -y update

# Install dependencies
yum -y install augeas jq

# Install Puppet AIO
yum -y install http://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
augtool set /files/etc/yum.repos.d/puppetlabs-pc1.repo/puppetlabs-pc1/priority 1
yum -y install puppet-agent
chkconfig puppet on

# Configure Puppet
augtool set /files/etc/puppetlabs/puppet/puppet.conf/main/server ip-172-31-39-174.eu-west-1.compute.internal
/opt/puppetlabs/bin/puppet resource host ip-172-31-39-174.eu-west-1.compute.internal ensure=present host_aliases=ip-172-31-39-174 ip=52.18.25.75

# Custom script for grabbing ec2 tags
mkdir -p /etc/facter/facts.d
cat <<EOF > /etc/facter/facts.d/ec2_tags.sh
#!/usr/bin/env bash
 
instanceId=\$(curl http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
region=\$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null | sed 's/[a-z]$//g')
 
/usr/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=\${instanceId}" --region \${region} | jq '.Tags[] | "ec2_tag_" + .Key + "=" + .Value' | tr [:upper:] [:lower:] | tr -d '"'
 
exit 0
EOF
chmod +x /etc/facter/facts.d/ec2_tags.sh

# Start Puppet
service puppet start
