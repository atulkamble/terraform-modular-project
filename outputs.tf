output "ec2_instance_id" {
  value = module.web_server.instance_id
}

output "ec2_public_ip" {
  value = module.web_server.public_ip
}

output "dev_instance_id" {
  value = module.dev.instance_id
}

output "dev_public_ip" {
  value = module.dev.public_ip
}

output "prod_instance_id" {
  value = module.prod.instance_id
}

output "prod_public_ip" {
  value = module.prod.public_ip
}
