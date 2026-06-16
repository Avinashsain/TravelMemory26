output "web_server_public_ip" {
  description = "Public IP address of the web server EC2 instance"
  value       = aws_eip.web.public_ip
}

output "web_server_instance_id" {
  description = "Instance ID of the web server"
  value       = aws_instance.web.id
}

output "db_server_private_ip" {
  description = "Private IP address of the database server"
  value       = aws_instance.db.private_ip
}

output "db_server_instance_id" {
  description = "Instance ID of the database server"
  value       = aws_instance.db.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "ansible_inventory_snippet" {
  description = "Paste this into your Ansible inventory file"
  value       = <<-EOT
    [webservers]
    ${aws_eip.web.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/travelmemory

    [databases]
    ${aws_instance.db.private_ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/travelmemory ansible_ssh_common_args='-o ProxyJump=ec2-user@${aws_eip.web.public_ip}'
  EOT
}
