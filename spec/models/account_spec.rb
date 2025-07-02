# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'associations' do
    it { should have_many(:users).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:account)).to be_valid
    end

    it 'can create account with users' do
      account = create(:account, :with_users)
      expect(account.users.count).to eq(3)
    end
  end

  describe '#destroy' do
    it 'destroys associated users' do
      account = create(:account)
      users = create_list(:user, 2, account: account)

      expect { account.destroy }.to change { User.count }.by(-2)
    end
  end
end
