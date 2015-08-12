class puppet_aws_demo::web3 {

  include '::nginx'

  nginx::resource::vhost { '_':
    www_root => '/usr/share/nginx',
  }

  file { '/usr/share/nginx/index.html':
    ensure  => 'file',
    owner   => 'nginx',
    group   => 'nginx',
    mode    => '0755',
    content => 'This is Web3!',
    require => Package['nginx'],
    before  => Service['nginx'],
  }


}
