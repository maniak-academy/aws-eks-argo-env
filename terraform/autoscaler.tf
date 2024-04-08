/* 
resource "kubernetes_namespace" "cluster_autoscaler" {
  depends_on = [module.eks]
  metadata {
    name = local.namespace
  }
} */


resource "helm_release" "cluster_autoscaler" {
  depends_on = [aws_eks_cluster.myekscluster,
    module.aws_load_balancer_controller
  ]
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  name       = "cluster-autoscaler"
  version    = "9.36.0"
  repository = "https://kubernetes.github.io/autoscaler"

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.myekscluster.id
  }

  # Terraform keeps this in state, so we get it automatically!
  set {
    name  = "cloudProvder"
    value = "aws"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.myekscluster.id
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler-chart-service-account"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_admin.iam_role_arn
  }

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }
}
