
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd_helm" {
  depends_on = [module.aws_load_balancer_controller,
    kubernetes_namespace.argocd
  ]
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.8"

  name      = "argocd"
  namespace = "argocd"

  set {
    name  = "global.domain"
    value = "argocd.maniak.academy"
  }
}
