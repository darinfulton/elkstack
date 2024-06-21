output "vpc_id" {
  value = aws_vpc.primary-vpc.id
}

output "vpc_arn" {
  value = aws_vpc.primary-vpc.arn
}

output "public_ip" {
  value = aws_eip.eip.public_ip
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "es_host_ip" {
  value = aws_instance.es_host.private_ip
}

output "elasticsearch_dnsname" {
  value = aws_lb.es_lb.dns_name
}

output "public_subnet_cidr_block" {
  value = [for subnet in aws_subnet.public : subnet.cidr_block]
}
output "private_subnet_cidr_block" {
  value = [for subnet in aws_subnet.private : subnet.cidr_block]
}