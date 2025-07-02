# CLAUDE.md

## Project Overview
Rails API Template - A production-ready Rails API template with OAuth2 authentication (Devise + Doorkeeper), multi-tenant architecture, and admin interface. This template follows the structure and patterns from the ironmove project but simplified to only User and Account entities.

## Key Features
- **Devise + Doorkeeper** authentication (email/password with OAuth2)
- **Multi-tenant architecture** with Account model
- **Role-based users** (employee, admin, owner)
- **Admin dashboard** using Administrate with HTTP Basic Auth
- **JSONAPI serialization** for all API responses
- **RSpec testing** with FactoryBot (40 passing tests)
- **Phone number validation** with normalization
- **Bruno API collection** for endpoint testing
- **Code quality tools** (RuboCop & Brakeman)
- **Single migration file** for easy setup
- **AWS S3 ready** with Active Storage
- **Background jobs** with Solid Queue
- **Deployment ready** with Docker & Kamal

## Development Commands

### Server & Console
- `rails server` - Start the development server (port 3000)
- `rails console` - Open Rails console
- `rails console --sandbox` - Console with rollback on exit
- `rails dbconsole` - Open database console

### Database
- `rails db:create` - Create database
- `rails db:migrate` - Run migrations
- `rails db:seed` - Seed development data (creates OAuth app & test users)
- `rails db:reset` - Drop, create, migrate, and seed
- `rails db:setup` - Create, load schema, and seed
- `rails db:test:prepare` - Prepare test database
- `rails db:migrate:status` - Check migration status

### Testing Commands
- `bundle exec rspec` - Run full test suite (40 tests)
- `bundle exec rspec spec/models/` - Run model tests
- `bundle exec rspec spec/requests/` - Run request/API tests
- `bundle exec rspec spec/models/user_spec.rb` - Run specific file
- `bundle exec rspec spec/models/user_spec.rb:15` - Run specific test
- `COVERAGE=true bundle exec rspec` - Run with coverage report

### Code Quality Commands
- `bundle exec rubocop` - Run Ruby linter
- `bundle exec rubocop -a` - Auto-fix safe violations
- `bundle exec rubocop -A` - Auto-fix all violations
- `bundle exec rubocop --regenerate-todo` - Update TODO file
- `bundle exec brakeman` - Run security scanner
- `bundle exec brakeman -A` - Detailed security output
- `bundle exec brakeman -o report.html` - Generate HTML report

### Background Jobs
- `bundle exec rake solid_queue:start` - Start job worker
- `rails runner "SolidQueue::Job.destroy_all"` - Clear all jobs

### Deployment Commands

#### Docker Commands
- `docker build -t rails-api-template .` - Build production image
- `docker run -d -p 80:80 -e RAILS_MASTER_KEY=$(cat config/master.key) rails-api-template` - Run container
- `docker exec -it rails-api-template /rails/bin/rails console` - Rails console in container
- `docker logs rails-api-template` - View container logs

#### Fly.io Commands
- `fly launch --no-deploy` - Initialize new Fly app
- `fly deploy` - Deploy to Fly.io
- `fly deploy --remote-only` - Deploy using remote builder
- `fly status` - Check app status
- `fly logs` - Stream application logs
- `fly ssh console` - SSH into running app
- `fly ssh console -C "/rails/bin/rails console"` - Remote Rails console
- `fly ssh console -C "/rails/bin/rails db:migrate"` - Run migrations
- `fly secrets list` - List configured secrets
- `fly secrets set KEY=value` - Set secret environment variable
- `fly scale count 2` - Scale to 2 instances
- `fly scale vm dedicated-cpu-1x --memory 1024` - Change VM size
- `fly postgres create` - Create PostgreSQL database
- `fly postgres attach <db-name>` - Attach database to app

## Bruno API Collection

The project includes a Bruno collection in `/bruno` with:
- **auth/** - OAuth token operations (get, refresh, revoke)
- **users/** - User management (create, show current user)
- **accounts/** - Account endpoints (list accounts)
- **images/** - S3 presigned URLs for downloads
- **presigned_urls/** - S3 presigned URLs for uploads
- **docs/** - Getting started documentation

To use:
1. Install Bruno (https://www.usebruno.com/)
2. Open the collection from `bruno/bruno.json`
3. Set environment variables for your local setup

## OAuth Setup

### Quick Start (Development)
```bash
rails db:seed
# Outputs Client ID and Secret
```

### Manual Creation
```ruby
rails console
app = Doorkeeper::Application.create!(
  name: 'My App',
  redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
  scopes: ''
)
puts "Client ID: #{app.uid}"
puts "Client Secret: #{app.secret}"
```

## Test Users (Development)
- Admin: `admin@example.com` / `password123`
- User: `user@example.com` / `password123`

## Admin Dashboard
- URL: http://localhost:3000/admin
- Auth: HTTP Basic (set via ADMIN_USERNAME and ADMIN_PASSWORD env vars)

## Environment Variables
Create a `.env` file with:
```
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_password
```

## Project Structure
```
app/
├── controllers/
│   ├── admin/          # Administrate controllers
│   └── api/            # API endpoints
├── dashboards/         # Administrate configuration
├── models/             # User, Account models
├── serializers/        # JSONAPI serializers
└── views/              # Email templates

config/
├── initializers/
│   ├── cors.rb         # CORS configuration
│   ├── devise.rb       # Devise setup with custom failure app
│   └── doorkeeper.rb   # OAuth2 configuration
└── routes.rb           # API routes matching ironmove structure

db/migrate/
└── 20250702000001_create_initial_schema.rb  # Single migration file

spec/
├── factories/          # FactoryBot test data
├── models/             # Model tests  
├── requests/           # API endpoint tests
└── support/            # Test helpers
```

## Authentication Flow
1. **User Registration**: POST /api/users (no auth required)
2. **Get OAuth Token**: POST /oauth/token (password grant)
3. **Access Protected Resources**: Use Bearer token in Authorization header
4. **Refresh Token**: POST /oauth/token (refresh_token grant)
5. **Password Reset**: Handled via Devise's default HTML forms

## Recent Changes/Setup Notes
- Created from ironmove project structure
- Added Devise for user authentication (replaced has_secure_password)
- Configured Devise to work with Doorkeeper OAuth2
- Removed all SMS/auth_code functionality
- Consolidated all migrations into single file
- Updated routes to match ironmove patterns
- Added password reset via API endpoints
- Made account_id optional for users
- Set up custom failure app for JSON API responses
- All tests passing (40 examples)

## Common Tasks

### Adding a New Model
1. Generate model: `rails g model ModelName field:type`
2. Add to single migration or create new: `rails g migration AddModelName`
3. Run migration: `rails db:migrate`
4. Create serializer in `app/serializers/model_name_serializer.rb`
5. Create API controller in `app/controllers/api/model_names_controller.rb`
6. Add routes to `config/routes.rb` (API and admin)
7. Create admin dashboard: `rails g administrate:dashboard ModelName`
8. Create factory: `spec/factories/model_names.rb`
9. Create tests: `spec/models/model_name_spec.rb` and `spec/requests/api/model_names_spec.rb`

### Debugging
- Check logs: `tail -f log/development.log`
- SQL logging in console: `ActiveRecord::Base.logger = Logger.new(STDOUT)`
- List routes: `rails routes | grep api`
- Check schema: `cat db/schema.rb`
- Test OAuth in console: `Doorkeeper::Application.first`
- Check current user: `User.find_by(email: 'user@example.com')`

## Notes
- Main branch: `main`
- Ruby version: 3.2+
- Rails version: 8.0.2
- Database: PostgreSQL 14+
- Test framework: RSpec with FactoryBot
- API format: JSONAPI
- Authentication: Devise + Doorkeeper (OAuth2)
- Based on ironmove project patterns
- S3 integration for file uploads/downloads with presigned URLs