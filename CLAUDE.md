# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CloudWatch Aggregator is a Flask-based HTTP service that manages batch logging to CloudWatch and Splunk from HTTP POST requests with JSON payloads in a non-blocking manner. The application acts as a logging proxy/aggregator, accepting logs via HTTP and forwarding them to configured logging platforms.

## Development Commands

### Setup
```bash
# Copy environment template and configure logging platforms
cp .env.example .env
# Edit .env with your CloudWatch/Splunk credentials

# Install dependencies
pipenv install
pipenv shell
```

### Build and Run
```bash
# Build Docker image only
./scripts/build

# Build and run with Docker Compose
./scripts/run

# Development mode (with Flask dev server)
# Set FLASK_ENV=development in .env, then:
./run-server.sh
# Runs on port 5000 with auto-reload

# Production mode
# Set FLASK_ENV=production and PUBLIC_PORT in .env, then:
# Uses gunicorn with 4 workers on $PUBLIC_PORT
```

### Linting
```bash
# Install pre-commit hooks (one-time setup)
pre-commit install

# Run linting manually
pre-commit run -a
```

The project uses:
- `black` formatter with line length 119, targeting Python 3.12
- `trailing-whitespace`, `end-of-file-fixer`, and `debug-statements` checks

## Architecture

### Core Components

**app/__init__.py**: Flask application initialization with strict slashes disabled.

**app/log.py**: Main application logic containing:
- `/ping` endpoint for health checks
- `/log/<log_stream>` POST endpoint that accepts JSON log data
- `Cache` class that maintains active stream handlers and allowed stream list
- Log handler management (CloudWatch and Splunk)
- Stream validation against `CLOUD_WATCH_ALLOWED_STREAMS`

**app/utils.py**: Utility functions, primarily `truthy_string()` for converting string environment variables to booleans.

### Configuration System

The application supports two configuration modes:

1. **Clowder Mode** (Red Hat App SRE platform): Uses `app_common_python.LoadedConfig` for CloudWatch credentials
2. **Environment Variables**: Standard `.env` file configuration

Configuration is determined by `isClowderEnabled()` check in app/log.py:14-25.

### Logging Flow

1. POST request arrives at `/log/<log_stream>` with JSON payload
2. Stream name validated against `CLOUD_WATCH_ALLOWED_STREAMS` allowlist
3. Logger created/retrieved for the stream
4. Handlers added to logger if not already cached (CloudWatch and/or Splunk based on config)
5. Log message written asynchronously to configured platforms
6. HTTP 202 (Accepted) response returned immediately

### Handler Caching

Log handlers are cached per stream in `Cache.active_stream_handlers` (app/log.py:34-36) to avoid recreating boto3 clients and handler objects on every request. The caching logic in `add_log_handlers()` (app/log.py:63-69) checks if a handler exists before creating new ones. Once a handler is created for a stream, it's reused for all subsequent logs to that stream.

### Environment Variables

Required environment variables depend on which logging platforms are enabled:

- `LOG_TO_CLOUDWATCH` and `LOG_TO_SPLUNK`: Boolean flags to enable platforms
- `CLOUD_WATCH_ALLOWED_STREAMS`: Comma-separated allowlist of valid stream names
- See README.md for complete CloudWatch and Splunk configuration variables

## Python Version

The project uses Python 3.12 (specified in Pipfile and Dockerfile).

## Container Base Image

The Dockerfile uses the Hummingbird Python 3.12 builder image (`registry.access.redhat.com/hi/python:3.12-builder`), which provides Python 3.12 pre-installed. This simplifies the Dockerfile by removing the need to manually install Python and create symlinks.

## Key Dependencies

- Flask 3.1.2: Web framework
- watchtower 3.4.0: CloudWatch logging integration
- splunk-handler: Splunk logging integration
- boto3 (via watchtower): AWS SDK for CloudWatch
- gunicorn 24.1.1: Production WSGI server
- app-common-python 0.2.9: Red Hat Clowder platform integration
