provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

locals {
  appenv        = "${var.app}-${var.env}"
  bucket        = "${var.project_id}-${local.appenv}"
}

terraform {
  backend "gcs" {
    bucket  = "${var.project_id}-tfstate"
    prefix  = "terraform/state"
  }
}

# ------------------------------------------------------------------------------
# Artifact Repository 
# ------------------------------------------------------------------------------

resource "google_artifact_registry_repository" "docker-repo" {
  provider      = google-beta

  location      = var.region
  repository_id = "${local.appenv}-repository"
  format        = "DOCKER"
}

# ------------------------------------------------------------------------------
# Adding SSH Public Key in Project Meta Data
# ------------------------------------------------------------------------------

# resource "google_compute_project_metadata_item" "ssh-keys" {
#   key   = "ssh-keys"
#   value = "dennislee:${file("${var.public_key}")}"
# }

#-------------------------------------------------------------------------------
# Service Account
#-------------------------------------------------------------------------------

# data "google_service_account" "sa" {
#   account_id   = "cloud_user_p_09003614@linuxacademygclabs.com"
# }
#
# resource "google_service_account" "sa" {
#   account_id   = "${local.appenv}-app-sa"
#   display_name = "${local.appenv}-app-sa"
# }
# 
# resource "google_project_iam_binding" "sa-pubsub-iam" {
#   role    = "roles/pubsub.subscriber"
#   members = ["serviceAccount:${google_service_account.sa.email}"]
# }
# 
# resource "google_project_iam_binding" "sa-bucket-iam" {
#   role    = "roles/storage.objectAdmin"
#   members = ["serviceAccount:${google_service_account.sa.email}"]
# }

#-------------------------------------------------------------------------------
# PubSub
#-------------------------------------------------------------------------------

resource "google_pubsub_topic" "pub-bq-topic" {
  name = "${local.appenv}-pub-msg-topic"
}

resource "google_pubsub_subscription" "pub-bq-subscription" {
  name  = "${local.appenv}-pub-msg-subscription"
  topic = google_pubsub_topic.pub-bq-topic.name

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
}

# ------------------------------------------------------------------------------
# Cloud storage 
# ------------------------------------------------------------------------------

resource "google_storage_bucket" "image-bucket" {
  name     = "${local.appenv}-bucket"
}


# # ------------------------------------------------------------------------------
# # Upload Processer's GCP Function
# # ------------------------------------------------------------------------------
# 
# resource "google_storage_bucket_object" "archive" {
#   name   = "index.zip"
#   bucket = google_storage_bucket.image-bucket.name
#   source = "../processor/index.js"
# }
# 
# resource "google_cloudfunctions_function" "function" {
#   name        = "${local.appenv}-func-processor"
#   description = "Processor"
#   region      = var.region
#   runtime     = "nodejs10"
# 
#   available_memory_mb   = 128
#   source_archive_bucket = google_storage_bucket.image-bucket.name
#   source_archive_object = google_storage_bucket_object.archive.name
#   event_trigger {
#     event_type = "google.storage.object.finalize"
#     resource   = google_pubsub_subscription.pub-bq-subscription.name
#   }
#   timeout               = 60
#   entry_point           = "process"
# }
