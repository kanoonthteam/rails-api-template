# frozen_string_literal: true

class User < ApplicationRecord
  include ActiveModel::Attributes

  enum :role, { employee: 0, admin: 1, owner: 2 }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :account, optional: true

  validates :email, format: URI::MailTo::EMAIL_REGEXP, if: :owner?
  validates :phone_number, presence: true
  validates :name, presence: true

  phony_normalize :phone_number

  # Ensure phone number is in a valid format
  validates :phone_number, phony_plausible: true

  # owner? method is provided by enum

  def self.authenticate(email, password)
    user = User.find_for_authentication(email: email)
    user&.valid_password?(password) ? user : nil
  end

end
