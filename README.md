# gcs-agent

**gcs-agent** is a conversational AI agent that reads files from Google Cloud Storage and answers questions about their contents. Give it a GCS URI (e.g. `gs://my-bucket/path/to/file.txt`) and it fetches the file, then lets you ask follow-up questions about it in natural language. It is built on the [Google Agent Development Kit (ADK)](https://adk.dev/) using Gemini 3.6 Flash, and it supports the [A2A Protocol](https://a2a-protocol.org/) for interoperability with other agents and tools.

## Project Structure

```
gcs-agent/
├── app/                      # Core agent code
│   ├── agent.py              # Agent definition, GCS read tool, and model config
│   ├── fast_api_app.py       # FastAPI server with A2A and Reasoning Engine routes
│   └── app_utils/            # Shared services, A2A wiring, and type definitions
├── deployment/               # Terraform infrastructure scripts
│   └── terraform/
├── tests/                    # Unit, integration, evaluation, and load tests
│   ├── unit/
│   ├── integration/
│   ├── eval/                 # Evaluation datasets and grading configs
│   └── load_test/            # Locust-based load testing
├── Dockerfile                # Container image definition
├── agents-cli-manifest.yaml  # agents-cli project configuration
└── pyproject.toml            # Python dependencies
```

## Requirements

- **uv** — Python package manager ([install](https://docs.astral.sh/uv/getting-started/installation/))
- **agents-cli** — Google Agents CLI: `uv tool install google-agents-cli`
- **Google Cloud SDK** — For GCP services ([install](https://cloud.google.com/sdk/docs/install))
- **Terraform** — For infrastructure deployment ([install](https://developer.hashicorp.com/terraform/downloads))

## Quick Start

Install `agents-cli` and its dependencies:

```bash
uvx google-agents-cli setup
agents-cli install
```

Test the agent interactively:

```bash
agents-cli playground
```

## Commands

| Command | Description |
|---------|-------------|
| `agents-cli install` | Install Python dependencies using uv |
| `agents-cli playground` | Launch local development server with auto-reload |
| `agents-cli lint` | Run code quality checks (ruff, ty, codespell) |
| `agents-cli eval generate` | Run agent on eval dataset and produce traces |
| `agents-cli eval grade` | Score traces against evaluation metrics |
| `agents-cli eval compare BASE CAND` | Diff two grade-result files for regression checking |
| `agents-cli eval analyze RESULTS` | Cluster failure modes from a grade-results file |
| `agents-cli eval optimize` | Auto-tune agent prompts using eval data |
| `uv run pytest tests/unit tests/integration` | Run unit and integration tests |
| `agents-cli deploy` | Deploy agent to Google Cloud Agent Runtime |
| `agents-cli publish gemini-enterprise` | Register deployed agent with Gemini Enterprise |
| `agents-cli infra single-project` | Provision single-project infrastructure via Terraform |
| `agents-cli infra cicd` | Set up full CI/CD pipeline and infrastructure |
| `agents-cli scaffold upgrade` | Upgrade project to the latest agents-cli template version |

## Documentation

| Document | What it covers | When to consult |
|----------|---------------|-----------------|
| [Evaluation Datasets](tests/eval/datasets/README.md) | Dataset format, eval commands, custom dataset creation, and available metrics | When writing or running evaluation cases |
| [Load Testing](tests/load_test/README.md) | Locust-based load test setup and execution against a deployed agent | When performance testing a deployed instance |

## Deployment

```bash
gcloud config set project <your-project-id>
agents-cli deploy
```

For production infrastructure with CI/CD:

```bash
agents-cli infra cicd
```

## Observability

Built-in OpenTelemetry instrumentation exports traces and metrics to Cloud Trace, BigQuery, and Cloud Logging when `GOOGLE_CLOUD_AGENT_ENGINE_ENABLE_TELEMETRY=true`.

## A2A Protocol

This agent exposes an A2A-compatible endpoint at `/a2a/app`. Use the [A2A Inspector](https://github.com/a2aproject/a2a-inspector) to test interoperability with other A2A agents.

## Contributing

Open a pull request against the `main` branch.
