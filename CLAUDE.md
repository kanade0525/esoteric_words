# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EsotericWord is a Rails 7 application for managing Japanese esoteric words (難解な単語). It runs serverless on AWS Lambda using the Lamby framework.

## Essential Commands

### Development
```bash
# Setup the project
./bin/setup

# Run tests
./bin/test

# Run linter (with auto-fix)
bundle exec rubocop -A

# Start Rails server locally
bundle exec rails server

# Rails console
bundle exec rails console

# Run a single test file
bundle exec rails test test/controllers/questions_controller_test.rb

# Run a specific test method
bundle exec rails test test/controllers/questions_controller_test.rb -n test_should_get_index
```

### DynamoDB Local
```bash
# Start DynamoDB Local
docker-compose up -d dynamodb-local

# Stop DynamoDB Local
docker-compose down

# View DynamoDB Local logs
docker-compose logs dynamodb-local
```

### Deployment
```bash
# Deploy to AWS Lambda
./bin/deploy
```

## Architecture Overview

### Technology Stack
- **Rails 7** with Ruby 3.2
- **DynamoDB** database (using Aws::Record)
- **Slim** templating engine
- **Bootstrap 5.3** CSS framework
- **Importmap** for JavaScript (no webpack)
- **AWS Lambda** deployment via Lamby

### Key Architectural Decisions

1. **Serverless Architecture**: The app is designed to run on AWS Lambda, not traditional servers. The Lamby gem handles Rails-to-Lambda integration.

2. **DynamoDB with Aws::Record**: Uses AWS DynamoDB instead of traditional RDBMS. The Question model uses Aws::Record for DynamoDB integration. ActiveRecord is disabled.

3. **No JavaScript Build Process**: Uses Rails' importmap instead of webpack/node. JavaScript dependencies are loaded directly from CDNs.

4. **Admin Namespace**: Admin functionality is isolated under `/admins` routes with dedicated controllers in `app/controllers/admins/`.

5. **I18n First**: Japanese is the default locale. All user-facing strings should use Rails i18n helpers.

### Project Structure

```
app/
├── controllers/
│   ├── admins/           # Admin namespace controllers
│   └── questions_controller.rb
├── models/
│   └── question.rb       # Single model with 'content' attribute
└── views/
    ├── admins/          # Admin views (CRUD operations)
    └── questions/       # Public views
```

### Important Files
- `config/routes.rb`: URL routing with admin namespace
- `config/locales/ja.yml`: Japanese translations
- `template.yaml`: AWS SAM configuration for Lambda deployment
- `Dockerfile`: Container setup for Lambda runtime
- `config/database.yml`: Database configuration (uses env vars in production)

### Common Tasks

When modifying the Question model or adding new features:
1. Question model uses Aws::Record - no migrations needed
2. DynamoDB tables are created automatically in development via initializer
3. Add translations to `config/locales/ja.yml`
4. Follow existing Slim template patterns in views
5. Run tests and rubocop before committing

### DynamoDB Notes
- Primary key is `id` (UUID string)
- Global secondary index on `content` field
- Development uses DynamoDB Local on port 8000
- Production uses IAM roles for authentication

The application is intentionally simple - avoid adding complexity unless necessary.