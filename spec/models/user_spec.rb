# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should belong_to(:account).optional }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid-email').for(:email) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:phone_number) }

    # Devise handles password validation
    it { should validate_presence_of(:password).on(:create) }
    it { should validate_length_of(:password).is_at_least(6).on(:create) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(employee: 0, admin: 1, owner: 2) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    it 'is invalid with invalid email' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'is invalid with invalid phone number' do
      user = build(:user, phone_number: '123')  # Too short to be valid
      expect(user).not_to be_valid
      expect(user.errors[:phone_number]).to be_present
    end
  end

  describe 'phone number normalization' do
    it 'normalizes phone number on save' do
      user = build(:user, phone_number: '+1 (234) 567-8900')
      user.save
      expect(user.phone_number).to eq('+12345678900')
    end
  end

  describe 'roles' do
    it 'creates user with employee role by default' do
      user = create(:user)
      expect(user.employee?).to be true
    end

    it 'can create admin user' do
      user = create(:user, :admin)
      expect(user.admin?).to be true
    end

    it 'can create owner user' do
      user = create(:user, :owner)
      expect(user.owner?).to be true
    end
  end

  describe 'password' do
    it 'requires password on create' do
      user = build(:user, password: nil, password_confirmation: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it 'requires password confirmation to match' do
      user = build(:user, password: 'password123', password_confirmation: 'different')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to be_present
    end
  end
end
