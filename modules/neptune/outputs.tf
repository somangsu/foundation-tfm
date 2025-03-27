output "neptune_endpoint" {
  value = aws_neptune_cluster.graph_db.endpoint
}

output "neptune_reader_endpoint" {
  value = aws_neptune_cluster.graph_db.reader_endpoint
}

output "sagemaker_notebook_url" {
  value = aws_sagemaker_notebook_instance.neptune.url
}

output "neptune_cluster_id" {
  value = aws_neptune_cluster.graph_db.id
}
