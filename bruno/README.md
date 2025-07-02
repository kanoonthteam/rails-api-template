# Rails API Template - Bruno Collection

This directory contains the Bruno API collection for testing and interacting with the Rails API Template.

## Installation

1. Install [Bruno](https://www.usebruno.com/) API client
2. Open Bruno and click "Open Collection"
3. Navigate to this `bruno` directory and select it

## Configuration

1. Select the "Development" environment in Bruno
2. Set the following environment variables:
   - `client_id`: Your OAuth application client ID
   - `client_secret`: Your OAuth application client secret

## Usage

1. Start with the `docs/getting-started` request to see the setup guide
2. Use `auth/token` to authenticate and get an access token
3. The token will be automatically saved and used for subsequent requests
4. Explore the API endpoints organized by resource type

## Directory Structure

```
bruno/
├── auth/              # OAuth authentication endpoints
│   ├── token.bru      # Get access token
│   ├── refresh.bru    # Refresh access token
│   └── revoke.bru     # Revoke token
├── users/             # User management
│   ├── signup.bru     # Create new user
│   ├── show.bru       # Get current user
│   └── update.bru     # Update user
├── accounts/          # Account management
│   ├── show.bru       # Get current account
│   └── update.bru     # Update account
└── docs/              # Documentation
    └── getting-started.bru  # Setup guide and overview
```

## Features

- Automatic token management (tokens are saved after authentication)
- Environment switching (Development/Production)
- JSON:API formatted requests and responses
- Comprehensive documentation for each endpoint
- Request examples with proper headers and body formats

## Testing Workflow

1. Health Check: `GET {{base_url}}/up`
2. Sign Up: `POST {{base_url}}/api/user/signup`
3. Get Token: `POST {{base_url}}/oauth/token`
4. Get User: `GET {{base_url}}/api/user`
5. Update User: `PATCH {{base_url}}/api/user`
6. Get Account: `GET {{base_url}}/api/account`

## Notes

- Access tokens expire after 24 hours by default
- Use refresh tokens to obtain new access tokens without re-authentication
- All authenticated endpoints require the `Authorization: Bearer <token>` header
- Phone numbers are automatically normalized and validated