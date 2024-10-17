### Frontend Deployment

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    labels = {
      app = "frontend"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }
      spec {
        container {
          image = "flappimen/booking_client:latest"
          name  = "frontend"
          image_pull_policy = "Always"
          port {
            container_port = 80
          }
          env {
            name  = "REACT_APP_API_URL"
            value = ""  # Тимчасово залишаємо порожнім або вкажіть інший URL
          }
          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
        }
      }
    }
  }
}

### Frontend Service

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend-service"
  }

  spec {
    selector = {
      app = "frontend"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

### Backend Deployment

resource "kubernetes_deployment" "backend" {
 metadata {
   name = "backend"
   labels = {
     app = "backend"
   }
 }

 spec {
   replicas = 2
   selector {
     match_labels = {
       app = "backend"
     }
   }
   template {
     metadata {
       labels = {
         app = "backend"
       }
       annotations = {
         redeploy-timestamp = "${timestamp()}"  # Форсоване оновлення
       }
     }
     spec {
       init_container {
         name    = "dns-check"
         image   = "bitnami/dnsutils:1"
         command = ["nslookup", "database-service.default.svc.cluster.local"]
         env {
           name  = "DB_HOST"
           value = "database-service.default.svc.cluster.local"
         }
       }
       container {
         image             = "flappimen/booking_api:v1.0.6"  
         name              = "backend"
         image_pull_policy = "Always"  # Гарантія завантаження останнього образу
         port {
           container_port = 8080
         }
         env {
           name  = "DB_HOST"
           value = "database-service.default.svc.cluster.local"
         }
         env {
           name  = "DB_PORT"
           value = "5432"
         }
         env {
           name  = "DB_NAME"
           value = "booking"
         }
         env {
           name  = "DB_USER"
           value = var.db_username
         }
         env {
           name = "DB_PASSWORD"
           value_from {
             secret_key_ref {
               name = "db-password-secret"
               key  = "password"
             }
           }
         }
         resources {  # Ресурси для стабільної роботи
           requests = {
             memory = "256Mi"
             cpu    = "250m"
           }
           limits = {
             memory = "512Mi"
             cpu    = "500m"
           }
         }
       }
     }
   }
 }
}

## Backend Service

resource "kubernetes_service" "backend" {
 metadata {
   name = "backend-service"
 }

 spec {
  selector = {
     app = "backend"
   }
   port {
     port        = 8080
     target_port = 8080
   }
   type = "ClusterIP"
 }
}

## Database Deployment

resource "kubernetes_deployment" "database" {
  metadata {
    name = "database"
    labels = {
      app = "database"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "database"
      }
    }
    template {
      metadata {
        labels = {
          app = "database"
        }
      }
      spec {
        container {
          image = "postgres:16.1"
          name  = "database"
          env {
            name  = "POSTGRES_USER"
            value = var.db_username
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "db-password-secret"
                key  = "password"
              }
            }
          }
          env {
            name  = "POSTGRES_DB"
            value = "booking"
          }
          port {
            container_port = 5432
          }
          resources {  # Ресурси для стабільної роботи
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
        }
      }
    }
  }
}

# Database Service

resource "kubernetes_service" "database" {
  metadata {
    name = "database-service"
  }

  spec {
    selector = {
      app = "database"
    }
    port {
      port        = 5432
      target_port = 5432
    }
    type = "ClusterIP"
  }
}
