class puppet_aws_demo::vpcs (
  $infras = hiera_hash('infras', undef)

) {

  if ($infras != undef) {
    create_resources('puppet_aws_demo::infra', $infras)
  }

}
