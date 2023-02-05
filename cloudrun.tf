resource "random_string" "random" {
  length  = 16
  special = false
}

resource "google_cloud_run_service" "default" {
  name     = "render-tasker-${random_string.random.result}"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/pushfiletobucket:latest"
        env {
          name  = "BUCKET_NAME"
          value = local.bucket_name
        }
        resources {
          limits = {
            memory = "256Mi"
            cpu    = "1000m"
          }
        }
      }
      service_account_name = google_service_account.sa.email
    }
    metadata {
      annotations = {
        "run.googleapis.com/ingress"       = "all"
        "autoscaling.knative.dev/minScale" = "0"
        "autoscaling.knative.dev/maxScale" = "10"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${google_service_account.sa.email}",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = var.project
  service     = google_cloud_run_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
