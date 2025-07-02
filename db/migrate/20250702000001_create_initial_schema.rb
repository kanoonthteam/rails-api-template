# frozen_string_literal: true

class CreateInitialSchema < ActiveRecord::Migration[8.0]
  def change
    # Enable PostgreSQL extensions
    enable_extension 'plpgsql'

    # Create accounts table
    create_table :accounts do |t|
      t.string :name
      t.timestamps
    end

    # Create OAuth applications table (for Doorkeeper)
    create_table :oauth_applications do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.string :secret, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, default: '', null: false
      t.boolean :confidential, default: true, null: false
      t.timestamps
    end

    add_index :oauth_applications, :uid, unique: true

    # Create OAuth access grants table (for Doorkeeper)
    create_table :oauth_access_grants do |t|
      t.bigint :resource_owner_id, null: false
      t.bigint :application_id, null: false
      t.string :token, null: false
      t.integer :expires_in, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, default: '', null: false
      t.datetime :created_at, null: false
      t.datetime :revoked_at
    end

    add_index :oauth_access_grants, :token, unique: true
    add_index :oauth_access_grants, :application_id
    add_index :oauth_access_grants, :resource_owner_id

    # Create OAuth access tokens table (for Doorkeeper)
    create_table :oauth_access_tokens do |t|
      t.bigint :resource_owner_id
      t.bigint :application_id
      t.string :token, null: false
      t.string :refresh_token
      t.integer :expires_in
      t.string :scopes
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string :previous_refresh_token, default: '', null: false
    end

    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :refresh_token, unique: true
    add_index :oauth_access_tokens, :application_id
    add_index :oauth_access_tokens, :resource_owner_id

    # Create users table with Devise fields
    create_table :users do |t|
      # Basic fields
      t.string :email, default: '', null: false
      t.string :name
      t.string :phone_number
      t.integer :role
      t.bigint :account_id

      # Devise fields
      t.string :encrypted_password, default: '', null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :account_id

    # Add foreign keys
    add_foreign_key :oauth_access_grants, :oauth_applications, column: :application_id
    add_foreign_key :oauth_access_tokens, :oauth_applications, column: :application_id
    add_foreign_key :users, :accounts
  end
end