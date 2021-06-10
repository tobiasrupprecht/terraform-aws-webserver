output "instance_id" {
  description = "ID of the EC2 instance"
  value       = [module.webserver-eu-west-1.instance_id, module.webserver-eu-north-1.instance_id]
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = [module.webserver-eu-west-1.instance_public_ip, module.webserver-eu-north-1.instance_public_ip]
}

output "DNS" {
  value = [module.webserver-eu-west-1.DNS, module.webserver-eu-north-1.DNS]
}