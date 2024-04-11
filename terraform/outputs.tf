output "cluster_name" {
  value = aws_eks_cluster.myekscluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.myekscluster.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.myekscluster.certificate_authority[0].data
}
output "mongdo_s3_bucket_name" {
  value = aws_s3_bucket.backup_bucket.bucket
  
}