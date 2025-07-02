# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# IMPORTANT: This seed file is for DEVELOPMENT ONLY
# Never run this in production or use these credentials in production

# Create a default OAuth application for development
if Rails.env.local?
  # Create default account
  account = Account.find_or_create_by!(name: 'Default Account')

  # Create admin user
  admin_user = User.find_or_create_by!(email: 'admin@example.com') do |user|
    user.password = 'password123'
    user.name = 'Admin User'
    user.phone_number = '+12125551234'
    user.role = 'admin'
    user.account = account
  end

  # Create regular user
  regular_user = User.find_or_create_by!(email: 'user@example.com') do |user|
    user.password = 'password123'
    user.name = 'Regular User'
    user.phone_number = '+12125551235'
    user.role = 'employee'
    user.account = account
  end

  # Create OAuth Application
  app = Doorkeeper::Application.find_or_create_by!(name: 'Default App') do |application|
    application.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    application.scopes = ''
  end

  puts "OAuth Application created:"
  puts "Client ID: #{app.uid}"
  puts "Client Secret: #{app.secret}"
  puts ""
  puts "Test users created:"
  puts "Admin: admin@example.com / password123"
  puts "User: user@example.com / password123"
end
