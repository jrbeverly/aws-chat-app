output "id" {
  value = local.id
}

output "execution_arn" {
  value = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${local.id}"
}

output "root_resource_id" {
  value = "arn:aws:apigateway:${var.region}::/restapis/${local.id}"
}
