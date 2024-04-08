
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.myekscluster.id
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.myekscluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.myekscluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubernetes" {

  host                   = aws_eks_cluster.myekscluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.myekscluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token

}