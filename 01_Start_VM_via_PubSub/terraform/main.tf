 provider "google" {
  project = "${var.project_id}"
}

locals {
  app           = "vm-pubsub"
  terraform     = "terraform"
  zone          = var.zone
  region        = var.region
  bucket        = "${var.project_id}-${local.app}"
}

# ------------------------------------------------------------------------------
# Adding SSH Public Key in Project Meta Data
# ------------------------------------------------------------------------------

resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "dennislee:${file("${var.public_key}")}"
}

#-------------------------------------------------------------------------------
# Service Account
#-------------------------------------------------------------------------------

resource "google_service_account" "sa" {
  account_id   = "${local.app}-app-sa"
  display_name = "${local.app}-app-sa"
}

resource "google_project_iam_binding" "sa-pubsub-iam" {
  role   = "roles/pubsub.subscriber"
  members = ["serviceAccount:${google_service_account.sa.email}"]
}

resource "google_project_iam_binding" "sa-bucket-iam" {
  role   = "roles/storage.objectAdmin"
  members = ["serviceAccount:${google_service_account.sa.email}"]
}

#-------------------------------------------------------------------------------
# PubSub
#-------------------------------------------------------------------------------

resource "google_pubsub_topic" "pub-start-topic" {
  name = "${local.app}-pub-start-topic"
}

resource "google_pubsub_topic" "pub-stop-topic" {
  name = "${local.app}-pub-stop-topic"
}

# ------------------------------------------------------------------------------
# Cloud storage 
# ------------------------------------------------------------------------------

data "archive_file" "hello_world_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../functions/adminvm"
  output_path = "${path.root}/function_src.zip"
}

resource "google_storage_bucket" "image-bucket" {
  name     = local.bucket
  location = "${local.region}"
}

resource "google_storage_bucket_object" "function-src" {
  name       = "function_src.zip"
  source     = "function_src.zip"
  bucket     = google_storage_bucket.image-bucket.name
  depends_on = ["data.archive_file.hello_world_zip"] 
}

# ------------------------------------------------------------------------------
# Functions 
# ------------------------------------------------------------------------------

resource "google_cloudfunctions_function" "function" {
  name        = "${local.app}-function"
  description = "Start stop VM"
  runtime     = "go113"
  region     = local.region

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.image-bucket.name
  source_archive_object = google_storage_bucket_object.function-src.name
  timeout               = 60
  entry_point           = "HelloPubSub"

  event_trigger {
    event_type          = "google.pubsub.topic.publish"
    resource            = google_pubsub_topic.pub-start-topic.name
  }

  labels = {
    my-label = "my-label-value"
  }

  environment_variables = {
    MY_ENV_VAR = "my-env-var-value"
  }
}


# ------------------------------------------------------------------------------
# Schedule job
# ------------------------------------------------------------------------------

resource "google_cloud_scheduler_job" "job" {
  name        = "poll-job"
  description = "poll job"
  schedule    = "*/1 * * * *"
  region      = local.region

  pubsub_target {
    topic_name = google_pubsub_topic.pub-start-topic.id
    data       = base64encode("Woody")
  }
}
