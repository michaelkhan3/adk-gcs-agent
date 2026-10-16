# ruff: noqa
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

from google.adk.agents import Agent
from google.adk.apps import App
from google.adk.models import Gemini
from google.cloud import storage
from google.genai import types


MODEL = "gemini-3.6-flash"


def read_gcs_file(gcs_uri: str) -> str:
    """Read a text file from Google Cloud Storage and return its contents.

    Args:
        gcs_uri: A GCS URI in the format gs://bucket-name/path/to/file.txt

    Returns:
        The text contents of the file, or an error message if the file cannot be read.
    """
    if not gcs_uri.startswith("gs://"):
        return "Error: URI must start with gs:// (e.g. gs://my-bucket/path/to/file.txt)"
    path = gcs_uri[5:]
    bucket_name, _, blob_name = path.partition("/")
    if not bucket_name or not blob_name:
        return "Error: Invalid GCS URI. Expected format: gs://bucket-name/path/to/file"
    try:
        client = storage.Client()
        return client.bucket(bucket_name).blob(blob_name).download_as_text()
    except Exception as e:
        return f"Error reading file: {e}"


root_agent = Agent(
    name="root_agent",
    model=Gemini(
        model=MODEL,
        retry_options=types.HttpRetryOptions(attempts=3),
    ),
    instruction=(
        "You are a helpful assistant that reads files from Google Cloud Storage. "
        "When the user provides a GCS URI (e.g. gs://bucket-name/path/to/file.txt), "
        "use the read_gcs_file tool to fetch its contents and present them clearly. "
        "Answer any follow-up questions based on the file content you retrieved."
    ),
    tools=[read_gcs_file],
)

app = App(
    root_agent=root_agent,
    name="app",
)
