# frozen_string_literal: true

class UserSerializer < JSONAPI::Serializable::Resource
  type "users"

  attributes :id, :email, :name, :phone_number, :role, :created_at, :updated_at

  belongs_to :account
end
