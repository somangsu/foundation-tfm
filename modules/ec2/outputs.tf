output "instance_id" {
  value = aws_instance.graph_db_poc.id
}

output "private_ip" {
  value = aws_instance.graph_db_poc.private_ip
}
