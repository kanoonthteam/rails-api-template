# Rails API Template

A production-ready Rails API template with OAuth2 authentication, multi-tenant architecture, and admin interface. This template provides a solid foundation for building SaaS applications, multi-tenant systems, or any API-first Rails application.

## Features

- **Rails 8.0.2** API-only application
- **PostgreSQL** database with single migration setup
- **Devise + Doorkeeper** authentication (email/password with OAuth2)
- **Multi-tenant** architecture with Account model
- **Administrate** admin dashboard with HTTP Basic Auth
- **JSONAPI** serialization standard
- **RSpec** testing framework with 40 passing tests
- **Role-based** user system (employee, admin, owner)
- **Phone number** validation and normalization
- **CORS** configured for API access
- **Code quality** tools (RuboCop, Brakeman)
- **Bruno API** collection for testing
- **Background jobs** with Solid Queue
- **AWS S3** ready for file uploads
- **Docker & Kamal** deployment ready

## Requirements

- Ruby 3.2+
- PostgreSQL 14+
- Rails 8.0.2

## Quick Start

### 1. Clone and Initial Setup

```bash
git clone <repository-url>
cd rails-api-template

# Install dependencies
bundle install

# Copy environment variables template
cp .env.example .env

# Edit .env file with your values
# - Set admin credentials
# - Configure database if using non-default settings
```

### 2. Database Setup

Update `config/database.yml` with your PostgreSQL credentials:

```yaml
development:
  <<: *default
  database: rails_api_template_development
  username: postgres
  password: password
  host: localhost
  port: 5432
```

Then create and setup the database:

```bash
rails db:create
rails db:migrate
rails db:seed
```

The seed file will create:
- A default OAuth application (check console output for Client ID/Secret)
- Test users: admin@example.com and user@example.com (password: password123)

### 3. Start the Server

```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Authentication

This template uses OAuth2 password flow via Doorkeeper with Devise for user authentication.

### Get Access Token

```bash
curl -X POST http://localhost:3000/oauth/token \
  -H "Content-Type: application/json" \
  -d '{
    "grant_type": "password",
    "username": "user@example.com",
    "password": "password123",
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET"
  }'
```

Response:
```json
{
  "access_token": "YOUR_ACCESS_TOKEN",
  "token_type": "Bearer",
  "expires_in": 86400,
  "refresh_token": "YOUR_REFRESH_TOKEN",
  "created_at": 1719902400
}
```

### Use Access Token

```bash
curl http://localhost:3000/api/users/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Refresh Access Token

```bash
curl -X POST http://localhost:3000/oauth/token \
  -H "Content-Type: application/json" \
  -d '{
    "grant_type": "refresh_token",
    "refresh_token": "YOUR_REFRESH_TOKEN",
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET"
  }'
```

## API Endpoints

### Authentication
- `POST /oauth/token` - Get access token (password or refresh_token grant)
- `POST /oauth/revoke` - Revoke access token
- `GET /oauth/token/info` - Token introspection

### User Management
- `POST /api/users` - Create new user (no auth required)
- `GET /api/users/me` - Get current user profile

### Account Management  
- `GET /api/accounts` - List accounts (returns user's account)

### File Management (S3)
- `POST /api/presigned_urls` - Get presigned URL for file upload
- `GET /api/images/:key` - Get presigned URL for file download

### Password Reset
Password reset is handled via Devise's default controllers (HTML forms, not API endpoints)

## Admin Dashboard

Access the admin dashboard at `/admin` with HTTP Basic Authentication:
- Username: Set via `ADMIN_USERNAME` env variable (default: admin)
- Password: Set via `ADMIN_PASSWORD` env variable

Create a `.env` file with:
```
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_password
```

## Models

### User
- `email` - User email (unique, used for authentication)
- `encrypted_password` - User password (Devise/bcrypt)
- `name` - User full name
- `phone_number` - User phone number (validated and normalized)
- `role` - User role (enum: employee, admin, owner)
- `account_id` - Associated account (optional)
- Devise fields: `reset_password_token`, `reset_password_sent_at`, `remember_created_at`

### Account
- `name` - Account/Organization name
- `users` - Associated users (has many)

### OAuth Models (Doorkeeper)
- `oauth_applications` - OAuth2 client applications
- `oauth_access_tokens` - Active access tokens
- `oauth_access_grants` - Authorization grants

## Testing

Run the test suite:

```bash
# Run all tests
bundle exec rspec

# Run specific test types
bundle exec rspec spec/models
bundle exec rspec spec/requests

# Run with coverage report
COVERAGE=true bundle exec rspec
```

Current test status: **40 examples, 0 failures**

## Bruno API Collection

The project includes a Bruno API collection for testing endpoints.

### Setup Bruno

1. [Download Bruno](https://www.usebruno.com/)
2. Open Bruno and select "Open Collection"
3. Navigate to the `bruno` directory in this project
4. Set environment variables:
   - `baseUrl`: `http://localhost:3000`
   - `clientId`: Your OAuth Client ID
   - `clientSecret`: Your OAuth Client Secret

### Collection Structure

```
bruno/
├── auth/          # OAuth token operations
├── users/         # User management
├── accounts/      # Account endpoints
├── images/        # Image download endpoints
├── presigned_urls/  # File upload URLs
└── docs/          # API documentation
```

## Development

### Add New Models

1. Generate model:
```bash
rails generate model ModelName field:type
rails db:migrate
```

2. Create admin dashboard:
```bash
rails generate administrate:dashboard ModelName
```

3. Add to routes:
```ruby
namespace :admin do
  resources :model_names
end

namespace :api do
  resources :model_names
end
```

4. Create API controller:
```bash
# Create app/controllers/api/model_names_controller.rb
# Inherit from ApplicationController
# Add Doorkeeper authentication
```

5. Create serializer:
```bash
# Create app/serializers/model_name_serializer.rb
# Use JSONAPI::Serializable::Resource
```

6. Create tests:
```bash
# Create spec/models/model_name_spec.rb
# Create spec/requests/api/model_names_spec.rb
# Create spec/factories/model_names.rb
```

### Code Quality

```bash
# Run RuboCop (Ruby linter)
rubocop                    # Check all files
rubocop -a                 # Auto-fix issues
rubocop -A                 # Auto-fix more aggressively
rubocop --parallel         # Run in parallel

# Run Brakeman (security scanner)
brakeman                   # Basic scan
brakeman -A                # Run all checks
brakeman -o report.html    # Generate HTML report

# Run both
rubocop && brakeman
```

**Current Status:**
- RuboCop: 1 offense (missing unique index on users.email)
- Brakeman: Clean (no security warnings)

## Project Structure

```
rails-api-template/
├── app/
│   ├── controllers/
│   │   ├── admin/         # Admin controllers
│   │   └── api/           # API controllers
│   ├── dashboards/        # Administrate configs
│   ├── models/            # User, Account
│   └── serializers/       # JSONAPI serializers
├── bruno/                 # API collection
│   ├── auth/              # OAuth endpoints
│   ├── users/             # User endpoints
│   └── accounts/          # Account endpoints
├── config/
│   ├── initializers/
│   │   ├── cors.rb        # CORS config
│   │   ├── devise.rb      # Devise config
│   │   └── doorkeeper.rb  # OAuth2 config
│   └── routes.rb          # API routes
├── db/
│   └── migrate/           # Single migration file
├── lib/
│   └── custom_failure_app.rb  # API error responses
└── spec/                  # RSpec tests
    ├── factories/         # FactoryBot
    ├── models/            # Model specs
    └── requests/          # API specs
```

## Response Format

All API responses follow the JSONAPI specification:

```json
{
  "data": {
    "id": "1",
    "type": "users",
    "attributes": {
      "email": "user@example.com",
      "name": "John Doe",
      "phone_number": "+12125551234",
      "role": "employee"
    },
    "relationships": {
      "account": {
        "data": {
          "id": "1",
          "type": "accounts"
        }
      }
    }
  }
}
```

## Deployment

This template includes configurations for Docker and Fly.io deployment.

### Docker Deployment

The Dockerfile is optimized for production Rails API deployments with:
- Multi-stage build for smaller final image
- PostgreSQL client and dependencies
- Non-root user for security
- Health check endpoint at `/up`
- Thruster for efficient request handling

#### Building the Docker Image

```bash
# Build the production image
docker build -t rails-api-template .

# Run locally with environment variables
docker run -d \
  -p 80:80 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  -e DATABASE_URL="postgresql://username:password@host:5432/dbname" \
  -e ADMIN_USERNAME="admin" \
  -e ADMIN_PASSWORD="secure_password" \
  --name rails-api-template \
  rails-api-template
```

### Fly.io Deployment

This template includes a `fly.toml` configuration for easy deployment to Fly.io.

#### Prerequisites

1. Install Fly CLI:
```bash
# macOS
brew install flyctl

# Linux
curl -L https://fly.io/install.sh | sh
```

2. Sign up/Login to Fly.io:
```bash
fly auth login
```

#### Initial Setup

1. Create a new Fly app:
```bash
fly launch --no-deploy
```

2. Create a PostgreSQL database:
```bash
fly postgres create --name rails-api-template-db
fly postgres attach rails-api-template-db
```

3. Set secrets:
```bash
# Set Rails master key
fly secrets set RAILS_MASTER_KEY=$(cat config/master.key)

# Set admin credentials
fly secrets set ADMIN_USERNAME=admin
fly secrets set ADMIN_PASSWORD=your_secure_password

# Set AWS credentials if using S3
fly secrets set AWS_ACCESS_KEY_ID=your_key
fly secrets set AWS_SECRET_ACCESS_KEY=your_secret
```

4. Deploy:
```bash
fly deploy
```

#### Subsequent Deployments

```bash
# Deploy latest changes
fly deploy

# Deploy with remote Docker builder (if local builds fail)
fly deploy --remote-only

# Check deployment status
fly status

# View logs
fly logs

# SSH into the app
fly ssh console

# Run Rails console
fly ssh console -C "/rails/bin/rails console"

# Run database migrations manually
fly ssh console -C "/rails/bin/rails db:migrate"
```

#### Scaling

```bash
# Scale horizontally
fly scale count 2

# Scale vertically
fly scale vm dedicated-cpu-1x --memory 1024

# Auto-scaling configuration
fly autoscale set min=1 max=5
```

### Environment Variables

Required environment variables for production:

- `RAILS_MASTER_KEY` - Rails master key for credentials
- `DATABASE_URL` - PostgreSQL connection string
- `ADMIN_USERNAME` - Admin dashboard username
- `ADMIN_PASSWORD` - Admin dashboard password

Optional for AWS S3:
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `AWS_REGION` - AWS region (default: us-east-1)
- `AWS_BUCKET_NAME` - S3 bucket name

### Health Checks

The application includes a health check endpoint at `/up` that verifies:
- Application is running
- Database connection is active
- Migrations are up to date

### Background Jobs

Solid Queue is configured for background job processing. The Fly.io configuration includes a separate worker process that runs automatically.

## Common Issues

### PostgreSQL Connection
If you see connection errors, ensure PostgreSQL is running:
```bash
# macOS
brew services start postgresql

# Linux
sudo systemctl start postgresql

# Docker
docker run -p 5432:5432 -e POSTGRES_PASSWORD=password postgres
```

### OAuth Client Creation
If seeds fail, manually create OAuth application:
```ruby
rails console
app = Doorkeeper::Application.create!(
  name: 'Default App',
  redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
)
puts "Client ID: #{app.uid}"
puts "Client Secret: #{app.secret}"
```

## AWS S3 Configuration

For file upload/download functionality, configure AWS credentials:

```bash
rails credentials:edit
```

Add the following structure:
```yaml
aws:
  region: us-east-1
  access_key_id: your_access_key_id
  secret_access_key: your_secret_access_key
  bucket_name: your-bucket-name
  endpoint_url_s3: https://s3.amazonaws.com  # Optional, for S3-compatible services
```

### File Upload Flow
1. Client requests presigned URL: `POST /api/presigned_urls`
2. Server returns presigned URL and object key
3. Client uploads file directly to S3 using the presigned URL
4. Client stores the object key for later retrieval

### File Download Flow
1. Client requests download URL: `GET /api/images/:key`
2. Server returns presigned URL for the S3 object
3. Client downloads file directly from S3

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`bundle exec rspec`)
4. Run linters (`rubocop && brakeman`)
5. Commit your changes
6. Push to the branch
7. Open a Pull Request

## Security

This template follows security best practices:

- All sensitive configuration uses environment variables
- Database passwords are never hardcoded
- Rails credentials used for production secrets
- OAuth tokens expire after 24 hours
- Admin dashboard uses HTTP Basic Auth
- All passwords are encrypted with bcrypt
- CORS is configured (update for production use)
- SSL is enforced in production

### Important Security Notes:

1. **Never commit `.env` files** - Only `.env.example` is tracked
2. **Keep `master.key` secure** - Required for production deployments
3. **Rotate credentials regularly** - OAuth secrets, API keys, etc.
4. **Use strong passwords** - The seed file passwords are for development only
5. **Configure CORS properly** - Current setting allows all origins (development only)

## License

MIT License