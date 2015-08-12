define puppet_aws_demo::infra (
  $ensure        = 'present',
  $region        = 'eu-west-1',
  $cidr_block    = '',
  $subnet_cidr_1 = '',
  $subnet_cidr_2 = '',
  $subnet_cidr_3 = '',
  $image_id      = 'ami-a10897d6',
  $instance_type = 't2.micro',

) {

  ec2_vpc { $title:
    ensure     => $ensure,
    region     => $region,
    cidr_block => $cidr_block,
  }
  ec2_vpc_internet_gateway { $title:
    ensure => $ensure,
    region => $region,
    vpc    => $title,
  }
  ec2_vpc_routetable { "${title}-web":
    ensure => $ensure,
    vpc    => $title,
    region => $region,
    routes => [
      {
        destination_cidr_block => $cidr_block,
        gateway                => 'local',
      },
      {
        destination_cidr_block => '0.0.0.0/0',
        gateway                => $title,
      },
    ],
  }
  ec2_vpc_subnet { "${title}-web1":
    ensure            => $ensure,
    vpc               => $title,
    region            => $region,
    cidr_block        => $subnet_cidr_1,
    availability_zone => "${region}a",
    route_table       => "${title}-web",
  }
  ec2_vpc_subnet { "${title}-web2":
    ensure            => $ensure,
    vpc               => $title,
    region            => $region,
    cidr_block        => $subnet_cidr_2,
    availability_zone => "${region}b",
    route_table       => "${title}-web",
  }
  ec2_vpc_subnet { "${title}-web3":
    ensure            => $ensure,
    vpc               => $title,
    region            => $region,
    cidr_block        => $subnet_cidr_3,
    availability_zone => "${region}c",
    route_table       => "${title}-web",
  }
  ec2_securitygroup { $title:
    ensure      => $ensure,
    region      => $region,
    ingress     => [
      {
        protocol => 'tcp',
        port     => '80',
        cidr     => '0.0.0.0/0',
      },
      {
        protocol => 'tcp',
        port     => '22',
        cidr     => '0.0.0.0/0',
      },
    ],
    description => $title,
    vpc         => $title,
  }
  ec2_instance { "${title}-web1":
    ensure                      => $ensure,
    region                      => $region,
    image_id                    => $image_id,
    instance_type               => $instance_type,
    monitoring                  => true,
    key_name                    => 'puppet-aws',
    security_groups             => [ $title ],
    subnet                      => "${title}-web1",
    associate_public_ip_address => true,
    user_data                   => file('puppet_aws_demo/firstboot.sh'),
    tags                        => {
      role => 'web1',
    },
    iam_instance_profile_arn    => 'arn:aws:iam::209654482675:role/puppetagent',
  }
  ec2_instance { "${title}-web2":
    ensure                      => $ensure,
    region                      => $region,
    image_id                    => $image_id,
    instance_type               => $instance_type,
    monitoring                  => true,
    key_name                    => 'puppet-aws',
    security_groups             => [ $title ],
    subnet                      => "${title}-web2",
    associate_public_ip_address => true,
    user_data                   => file('puppet_aws_demo/firstboot.sh'),
    tags                        => {
      role => 'web2',
    },
    iam_instance_profile_arn    => 'arn:aws:iam::209654482675:role/puppetagent',
  }
  ec2_instance { "${title}-web3":
    ensure                      => $ensure,
    region                      => $region,
    image_id                    => $image_id,
    instance_type               => $instance_type,
    monitoring                  => true,
    key_name                    => 'puppet-aws',
    security_groups             => [ $title ],
    subnet                      => "${title}-web3",
    associate_public_ip_address => true,
    user_data                   => file('puppet_aws_demo/firstboot.sh'),
    tags                        => {
      role => 'web3',
    },
    iam_instance_profile_arn    => 'arn:aws:iam::209654482675:role/puppetagent',
  }
  elb_loadbalancer { $title:
    ensure             => $ensure,
    region             => $region,
    subnets            => [ "${title}-web1", "${title}-web2", "${title}-web3" ],
    instances          => [ "${title}-web1", "${title}-web2", "${title}-web3" ],
    security_groups    => [ $title ],
    listeners          => [{
      protocol           => 'tcp',
      load_balancer_port => '80',
      instance_protocol  => 'tcp',
      instance_port      => '80',
    }],
  }

}
