locals {
  bucket_name = "render-export-${lower(random_string.random.result)}"
}

module "pubsub" {
  source  = "AckeeCZ/pubsub/gcp"
  version = "2.3.0"
  project = var.project
  topics = {
    "render-document" : {
      users : ["serviceAccount:${google_service_account.sa.email}",]
      retry_policy : {
        minimum_backoff : "300s"
        maximum_backoff : "600s"
      }
      push_config: {
        push_endpoint = one(google_cloud_run_service.default.status)["url"]
      }
    }
  }
}

resource "google_storage_bucket" "static_site" {
  name          = local.bucket_name
  location      = "europe-west3"
  force_destroy = true

  uniform_bucket_level_access = true

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD",]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}
