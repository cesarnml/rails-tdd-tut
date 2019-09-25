require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  describe "#validations" do
    it "should have valid factory" do
      user = create :user
      access_token = build :access_token, user: user
      expect(access_token).to be_valid
    end

    it "should validate the presence of the token" do
      access_token = build :access_token, token: ''
      expect(access_token).not_to be_valid
      expect(access_token.errors.messages[:token]).to include("can't be blank")
    end
  end

  describe "#new" do
    it "should have a token present after initialize" do
      expect(AccessToken.new.token).to be_present
    end

    it "should validate uniqueness of token" do
      user = create :user
      expect{ user.create_access_token }.to change { AccessToken.count }.by(1)
      expect(user.build_access_token).to be_valid
    end

    it "should generate a token once" do
    user = create :user
    access_token = user.create_access_token
    expect(access_token.token).to eq(access_token.reload.token)
    end
  end
end
