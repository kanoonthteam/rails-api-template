# frozen_string_literal: true

class AccountSerializer < JSONAPI::Serializable::Resource
  type "accounts"

  attributes :id, :name, :created_at, :updated_at

  has_many :users
end
