output "ec2_instance_id" {
  value = module.web_server.instance_id
}

output "ec2_public_ip" {
  value = module.web_server.public_ip
}
