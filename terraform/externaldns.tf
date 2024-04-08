data "aws_caller_identity" "current" {}

module "external_dns" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-external-dns.git?ref=0.2.0"

  cluster_name                     = aws_eks_cluster.myekscluster.name
  cluster_identity_oidc_issuer     = aws_eks_cluster.myekscluster.identity.0.oidc.0.issuer
  cluster_identity_oidc_issuer_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${aws_eks_cluster.myekscluster.identity.0.oidc.0.issuer}"

  helm_chart_version = "6.20.1"

  settings = {
    "policy"              = "sync" # Modify how DNS records are sychronized between sources and providers.
    "triggerLoopOnEvent"  = true
    "interval"            = "3m"
    "aws.batchChangeSize" = 3000
  }

  depends_on = [aws_eks_cluster.myekscluster,
    module.aws_load_balancer_controller
  ]
}