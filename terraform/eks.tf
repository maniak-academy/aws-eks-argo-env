

# EKS Cluster
resource "aws_eks_cluster" "myekscluster" {
  name     = "${var.project}-cluster"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = flatten([aws_subnet.public[*].id, aws_subnet.private[*].id])
    endpoint_private_access = true
    # endpoint_public_access  =  false
    endpoint_public_access = true
    public_access_cidrs    = ["0.0.0.0/0"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge(
    var.tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}


data "tls_certificate" "mytls" {
  url = aws_eks_cluster.myekscluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "openid_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.mytls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.myekscluster.identity[0].oidc[0].issuer
}

########################################################
# AWS Loadbalancer Controler(Ingress Controller)
module "aws_load_balancer_controller" {
  source     = "./modules/alb"
  depends_on = [aws_eks_cluster.myekscluster]

  cluster_identity_oidc_issuer     = aws_eks_cluster.myekscluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = aws_iam_openid_connect_provider.openid_provider.arn
  cluster_name                     = aws_eks_cluster.myekscluster.id
  helm_chart_version               = "1.7.2"
}

