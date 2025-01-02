# NanoPay.me Supabase Configuration

This repository contains the Supabase configuration and migrations for the NanoPay.me project.

![image](https://github.com/user-attachments/assets/9533527c-e578-4322-b918-db32bb675be3)

## Table of Contents

- [NanoPay.me Supabase Configuration](#nanopayme-supabase-configuration)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Getting Started](#getting-started)
    - [Installation](#installation)
    - [Setup](#setup)
    - [External Authentication (Optional):](#external-authentication-optional)
  - [Development Workflow](#development-workflow)
  - [Commands](#commands)
    - [Local Management](#local-management)
    - [Remote Management](#remote-management)
  - [Deployment](#deployment)
  - [Additional Resources](#additional-resources)

## Overview

- We use [Supabase](https://supabase.io/) as our database provider, utilizing its PostgreSQL database with RESTful API capabilities.
- Our project implements Row Level Security (RLS) to manage data access efficiently at the database level.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Node.js](https://nodejs.org/en/) (v18 or later)
- [Docker](https://www.docker.com/)
- [npm](https://www.npmjs.com/) (comes with Node.js)

## Getting Started

### Installation

Install the project dependencies, including the Supabase CLI:

```bash
npm install
```

### Setup

Initialize your local Supabase instance with the current migrations:

```bash
npm run setup
```

### External Authentication (Optional):

Configure External Authentication Methods:
If you need to use external authentication providers (such as GitHub, Google, etc.), update the config.toml file located at the root of the project. Add or modify the relevant sections for each auth provider you want to enable. For example:

```toml
[auth.external.github]
enabled = true
client_id = "your_client_id"
secret = "your_client_secret"
redirect_uri = "http://localhost:54321/auth/v1/callback"

# Add other providers as needed
# [auth.external.google]
# [auth.external.facebook]
# etc.
```

Make sure to replace the placeholder values with your actual OAuth credentials for each provider. For more information on configuring external authentication providers, refer to the [Supabase documentation](https://supabase.com/docs/guides/auth/auth-github).

## Development Workflow

Follow this workflow when making changes to the database:

1. Make changes to the local database (via UI or SQL)
2. Create local migrations
3. Test changes in the local instance
4. Push changes to the remote instance

## Commands

### Local Management

- **Check status of local Supabase instance:**

  ```bash
  npm run status
  ```

- **Start local Supabase instance:**

  ```bash
  npm run start
  ```

- **Stop local Supabase instance:**

  ```bash
  npm run stop
  ```

- **Reset local Supabase instance:**

  ```bash
  npm run reset
  ```

- **Show diff between migration files and local instance:**

  ```bash
  npm run diff
  ```

- **Create a migration sql file with current local diff:**

  ```bash
  npm run migrate "update_table_products"
  ```

- **Create an empty migration sql file:**

  ```bash
  npm run new "update_table_products"
  ```

- **Generate database types for TypeScript:**
  ```bash
  npm run types
  ```

### Remote Management

- **Link remote Supabase instance:**

  ```bash
  npm run link
  ```

- **Show diff between migration files and remote instance:**

  ```bash
  npm run diff:remote
  ```

- **Create a migration sql file with current remote diff:**

  ```bash
  npm run migrate:remote "update_table_products"
  ```

- **Push changes to remote instance:**

  ```bash
  npm run push
  ```

- **Pull changes from remote instance:**
  ```bash
  npm run pull
  ```
  Note: This should not be necessary if following the correct migration flow (local -> remote).

## Deployment

To deploy your project:

1. Create a new project in the [Supabase dashboard](https://app.supabase.io/)
2. Link your local instance to the remote instance using `npm run link`
3. Push your changes to the remote instance with `npm run push`
4. When using external authentication providers, make sure to update the env variables in the Supabase dashboard.

## Additional Resources

- For more commands, run:

  ```bash
  npx supabase --help
  ```

- [Supabase Official Documentation](https://supabase.io/docs/guides/database)

---

For any questions or issues, please open an issue in this repository or consult the Supabase documentation.
