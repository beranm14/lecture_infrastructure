resource "google_service_account" "sa" {
  account_id   = "render-tasker"
  display_name = "RenderTasker"
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/storage.admin"
    members = [
      "serviceAccount:${google_service_account.sa.email}",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "policy" {
  bucket = google_storage_bucket.static_site.name
  policy_data = data.google_iam_policy.admin.policy_data
}
