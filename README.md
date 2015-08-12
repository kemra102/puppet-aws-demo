# 0 to Production - Puppet & AWS

This repository contains the code & a copy of the slides used in my presentation at the [Nottingham AWS Meetup](http://www.meetup.com/Nottingham-AWS-Meetup/) in August 2015.

## Set-up Puppet Server & Pre-Requisites

1. Configure 2 IAM roles in AWS;

  a. One for the Puppet Server:
    ```json
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeRegions",
                "ec2:DescribeInstances",
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:DeleteTags",
                "ec2:CreateTags",
                "ec2:TerminateInstances",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancer",
                "ec2:DescribeSecurityGroups",
                "ec2:CreateSecurityGroups",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeVpcs",
                "ec2:CreateVpc",
                "ec2:DeleteVpc",
                "ec2:DescribeDhcpOptions",
                "ec2:CreateDhcpOptions",
                "ec2:DeleteDhcp_options",
                "ec2:DescribeCustomerGateways",
                "ec2:CreateCustomerGateway",
                "ec2:DeleteCustomerGateway",
                "ec2:DescribeInternetGateways",
                "ec2:CreateInternetGateway",
                "ec2:DeleteInternetGateway",
                "ec2:DetachInternetGateway",
                "ec2:DescribeRouteTables",
                "ec2:CreateRouteTable",
                "ec2:DeleteRouteTable",
                "ec2:CreateRoute",
                "ec2:DescribeSubnets",
                "ec2:CreateSubnet",
                "ec2:DeleteSubnet",
                "ec2:AssociateRouteTable",
                "ec2:DescribeVpnConnections",
                "ec2:CreateVpnConnection",
                "ec2:DeleteVpnConnection",
                "ec2:CreateVpnConnectionRoute",
                "ec2:DescribeVpnGateways",
                "ec2:CreateVpnGateway",
                "ec2:AttachVpnGateway",
                "ec2:DetachVpnGateway",
                "ec2:DeleteVpnGateway",
                "ec2:CreateTags",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:DeleteAutoScalingGroup",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:CreateLaunchConfiguration",
                "autoscaling:DeleteLaunchConfiguration",
                "autoscaling:DescribePolicies",
                "autoscaling:PutScalingPolicy",
                "autoscaling:DeletePolicy",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DeleteAlarms",
                "route53:ListResourceRecordSets",
                "route53:ListHostedZones",
                "route53:ChangeResourceRecordSets",
                "route53:CreateHostedZone",
                "route53:DeleteHostedZone",
                "rds:CreateDBInstance",
                "rds:ModifyDBInstance",
                "rds:DeleteDBInstance",
                "rds:DescribeDBInstances",
                "rds:AuthorizeDBSecurityGroupIngress",
                "rds:DescribeDBSecurityGroups",
                "rds:CreateDBSecurityGroup",
                "rds:DeleteDBSecurityGroup",
                "rds:DescribeDBParameterGroups"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
    }
    ```
  b. One for Puppet Agents:
    ```json
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1438596545411",
            "Action": [
                "ec2:DescribeImageAttribute",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInstances",
                "ec2:DescribePlacementGroups",
                "ec2:DescribeTags"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
    }
    ```
2. Create a key pair named **puppet-aws**.
3. Start an EC2 instance with the Puppet Server IAM role.
4. [Install Puppet Server](https://docs.puppetlabs.com/puppet/4.0/reference/install_linux.html).
5. Enable [Naïve Autosigning](https://docs.puppetlabs.com/puppet/latest/reference/ssl_autosign.html#enabling-nave-autosigning).
6. Install the [puppetlabs/aws](https://forge.puppetlabs.com/puppetlabs/aws) module:

  a. /opt/puppetlabs/bin/puppet module install puppetlabs/aws
7. Grab the Gem dependencies required by the puppetlabs/aws module:

  a. /opt/puppetlabs/puppet/bin/gem install aws-sdk-core retries --no-ri --no-rdoc
8. Install the [jfryman/nginx](https://forge.puppetlabs.com/jfryman/nginx) module:

  a. /opt/puppetlabs/bin/puppet module install jfryman/nginx
9. Install a copy of this repository:

  a. git clone https://github.com/kemra102/puppet_aws_demo.git /etc/puppetlabs/code/environments/production/modules/puppet_aws_demo
10. Update **/etc/puppetlabs/code/hiera.yaml**:

  ```yaml
  ---
  :backends:
    - yaml

  :yaml:
    :datadir: "/etc/puppetlabs/code/environments/%{::environment}/hiera"

  :hierarchy:
    - "roles/%{::role}"

  :logger: console
  ```
11. Update **/etc/puppetlabs/code/environments/production/environment.conf**:

  ```
  manifest = site.pp
  modulepath = modules:modules
  ```
12. Update **/etc/puppetlabs/code/environments/production/site.pp**:

  ```puppet
  hiera_include('classes')
  ```
13. Update **/etc/puppetlabs/code/environments/production/hiera/roles/puppetserver.yaml**:

  ```yaml
  ---
  classes:
    - puppet_aws_demo::vpcs
  ```
14. Update **/etc/puppetlabs/code/environments/production/hiera/roles/web1.yaml**:

  ```yaml
  ---
  classes:
    - puppet_aws_demo::web1
  ```
15. Repeat step 12 for web2 & web3.
16. Set custom fact:
  a. mkdir -p /etc/facter/facts.d && echo 'role=puppetserver' > /etc/facter/facts.d/custom.txt

## Building Your Infrastructure

To build your first AWS environment update **/etc/puppetlabs/code/environments/production/hiera/roles/puppetserver.yaml** with (making substitutions as you see fit):

```yaml
---
classes:
  - puppet_aws_demo::vpcs
infras:
  'prod-ireland':
    cidr_block: '10.0.0.0/16'
    subnet_cidr_1: '10.0.0.0/24'
    subnet_cidr_2: '10.0.1.0/24'
    subnet_cidr_3: '10.0.2.0/24'
```

Additional environments are set-up like so:

```yaml
---
classes:
  - puppet_aws_demo::vpcs
infras:
  'prod-ireland':
    cidr_block: '10.0.0.0/16'
    subnet_cidr_1: '10.0.0.0/24'
    subnet_cidr_2: '10.0.1.0/24'
    subnet_cidr_3: '10.0.2.0/24'
  'preprod-ireland':
    cidr_block: '10.1.0.0/16'
    subnet_cidr_1: '10.1.0.0/24'
    subnet_cidr_2: '10.1.1.0/24'
    subnet_cidr_3: '10.1.2.0/24'
```

This will give two completely isolated environments.

Once the config is written, just run Puppet on the Puppet Server: **/opt/puppetlabs/bin/puppet agent -t**
