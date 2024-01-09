provider "kubernetes" {
  config_context = var.kube_config_context
}

resource "kubernetes_deployment" "portfolio" {
  metadata {
    name = "portfolio"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "portfolio"
      }
    }

    template {
      metadata {
        labels = {
          app = "portfolio"
        }
      }

      spec {
        container {
          name  = "portfolio"
          image = "dvpslklarc/portfolio:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "portfolio" {
  metadata {
    name = "portfolio"
  }

  spec {
    selector = {
      app = "portfolio"
    }

    port {
      protocol   = "TCP"
      port       = 80
      target_port = 80
    }
  }
}
