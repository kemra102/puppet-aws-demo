class puppet-aws-demo::vpcs (
  $infras = hiera_hash('infras', undef)

) {

  if ($infras != undef) {
    create_resources('puppet-aws-demo::infra', $infras)
  }

}
