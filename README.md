# subway - Railway Deployment Manager

A train-themed Rails application for managing Railway deployments via the GraphQL API.

## Overview

subway allows you to:
- Deploy Docker images to Railway projects
- Track deployments in a local database
- Restart deployments
- Delete services to prevent overconsumption
- View deployment status and details

## Features

- **Session-based Authentication**: Store Railway API tokens securely per user
- **Project Selection**: Choose from your existing Railway projects
- **Docker Image Deployment**: Deploy any Docker image to Railway
- **Deployment Management**: View, restart, and delete deployments
- **Train-themed UI**: Beautiful, modern interface with railway-inspired design

## Prerequisites

- Ruby 3.x
- Rails 8.0.3
- SQLite3
- A Railway account with API token

## Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Set up the database:
   ```bash
   rails db:migrate
   ```

3. Start the development server:
   ```bash
   bin/dev
   ```

4. Visit `http://localhost:3000`

## Usage

### Getting Started

1. **Enter Railway API Token**: Visit the homepage and enter your Railway API token
   - Get your token from [Railway Dashboard](https://railway.app/account/tokens)

2. **Create a Deployment**:
   - Select a Railway project from the dropdown
   - Enter a Docker image name (e.g., `nginx:latest`)
   - Click "Deploy Service"

3. **Manage Deployments**:
   - View deployment details
   - See Railway service status and URLs
   - Restart deployments
   - Delete services

### API Integration

subway uses the Railway Public API (GraphQL):
- Endpoint: `https://backboard.railway.com/graphql/v2`
- Documentation: https://docs.railway.com/guides/public-api

### Routes

- `/` - Landing page (enter API token)
- `/deployments/new` - Create new deployment
- `/deployments/:id` - View deployment details
- `POST /deployments/:id/restart` - Restart deployment
- `DELETE /deployments/:id` - Delete deployment

## Architecture

### Models

- **User**: Stores Railway API keys
- **Deployment**: Tracks deployed services (project_id, service_id, docker_image, etc.)

### Services

- **RailwayClient**: GraphQL client for Railway API interactions
  - `fetch_projects` - Get user's projects
  - `create_service` - Deploy Docker image
  - `delete_service` - Remove service
  - `restart_deployment` - Restart deployment
  - `fetch_service_details` - Get service info

### Controllers

- **UsersController**: Handle API token submission
- **DeploymentsController**: CRUD operations for deployments

## Development

The app uses:
- **Rails 8.0.3** with modern defaults
- **Tailwind CSS** for styling
- **Phlex** for component structure
- **RubyUI** for UI components
- **Faraday** for HTTP requests
- **SQLite3** for database

## License

This project is open source.
