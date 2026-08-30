output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "IPv4 CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs ordered by their input position."
  value       = [for index in sort(keys(aws_subnet.public)) : aws_subnet.public[index].id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs ordered by their input position."
  value       = [for index in sort(keys(aws_subnet.private)) : aws_subnet.private[index].id]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}
