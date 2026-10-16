# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_vertex_ai_reasoning_engine" "app" {
  display_name = var.project_name
  description  = "Agent deployed via Terraform"
  region       = var.region
  project      = var.project_id

  spec {
    agent_framework = "google-adk"
    service_account = google_service_account.app_sa.email

    container_spec {
      image_uri = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_name}/${var.project_name}:${var.image_tag}"
    }

    deployment_spec {
      min_instances         = 1
      max_instances         = 10
      container_concurrency = 9

      resource_limits = {
        cpu    = "4"
        memory = "8Gi"
      }

      env {
        name  = "LOGS_BUCKET_NAME"
        value = google_storage_bucket.logs_data_bucket.name
      }

      # GOOGLE_CLOUD_PROJECT is reserved by Agent Runtime (the platform injects
      # it) and rejected in deployment_spec.env; GOOGLE_CLOUD_LOCATION is allowed.
      env {
        name  = "GOOGLE_CLOUD_LOCATION"
        value = "global"
      }

      env {
        name  = "GOOGLE_GENAI_USE_VERTEXAI"
        value = "True"
      }

      env {
        name  = "OTEL_SERVICE_NAME"
        value = "gcs-agent"
      }

      env {
        name  = "OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT"
        value = "NO_CONTENT"
      }

      env {
        name  = "ADK_CAPTURE_MESSAGE_CONTENT_IN_SPANS"
        value = "false"
      }

      env {
        name  = "OTEL_SEMCONV_STABILITY_OPT_IN"
        value = "gen_ai_latest_experimental"
      }

      env {
        name  = "OTEL_INSTRUMENTATION_GENAI_UPLOAD_FORMAT"
        value = "jsonl"
      }

      env {
        name  = "OTEL_INSTRUMENTATION_GENAI_COMPLETION_HOOK"
        value = "upload"
      }

      env {
        name  = "OTEL_INSTRUMENTATION_GENAI_UPLOAD_BASE_PATH"
        value = "gs://${google_storage_bucket.logs_data_bucket.name}/completions"
      }

      env {
        name  = "GOOGLE_CLOUD_AGENT_ENGINE_ENABLE_TELEMETRY"
        value = "true"
      }
    }
  }

  # IMAGE_PULL_BACKOFF prevention: ensure the service agent can pull from
  # Artifact Registry before the reasoning engine is created.
  depends_on = [
    google_project_service.services,
    google_project_iam_member.re_service_agent_ar_reader,
    google_artifact_registry_repository.agent_repo,
  ]
}
