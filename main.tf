

##
## Macros
locals {
  ns   = var.namespace
  name = var.name
  volume_name = "${local.name}-pgdata"
  secret_name = "${local.name}-secret"
  labels = {
    app = local.name
    managed_by = "terraform"
    project = "tf-tools-postgres"
  }
}

##
## Secrets
##
resource "kubernetes_secret" "this" {
  metadata {
    namespace = local.ns
    name      = local.secret_name
    labels = local.labels
  }  
  
  data = {
    POSTGRES_DB = var.db_name
    POSTGRES_USER = var.db_user
    POSTGRES_PASSWORD = random_password.this.result
  }
}

##
## Random password for the postgres user
##
resource "random_password" "this" {
  length           = 16
  special          = false
  override_special = "_%@"
}



##
## statefulset to deploy the application
##
resource "kubernetes_stateful_set" "this" {
  metadata {
    namespace = local.ns
    name      = local.name
    labels    = local.labels
  }

  spec {
    service_name = var.name

    selector {
      match_labels = merge(local.labels,{
        app = local.name
      })
    }

    volume_claim_template {
      metadata {
        name = local.volume_name
      }

      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.storage
          }
        }
      }
    }

    template {
      metadata {
        labels = merge(local.labels,{
          app = local.name
        })
      }

      spec {

        volume {
          name = local.volume_name
          persistent_volume_claim {
            claim_name = local.volume_name
          }
        }


        container {
          image = var.image
          name  = local.name

          port {
            name        = "postgres"
            container_port = var.pg_port
          }

          liveness_probe {
            tcp_socket {
              port = "postgres"
            }
          }

          env_from {
            secret_ref {
                name = local.secret_name
            }
          }

          volume_mount {
            name       = local.volume_name
            mount_path = "/var/lib/postgresql/data"
          }
        }
      }
    }
  }
}

##
## service to expose the application
##
resource "kubernetes_service" "this" {
  metadata {
    namespace = local.ns
    name      = local.name
    labels    = local.labels
  }

  spec {
    selector = merge(local.labels,{
      app = local.name
    })

    port {
      protocol = "TCP"
      name       = "postgres"
      port       = var.pg_port
      target_port = "postgres"
    }
  }
}

