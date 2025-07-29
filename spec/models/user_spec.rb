require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Validations" do
    it "is valid with a username, email, and password" do
      user = User.new(username: "jeet", email: "jeet@gmail.com", password: "jeet1234")
      expect(user).to be_valid
    end

    it "is invalid without a username" do
      user = User.new(username: nil, email: "jeet@gmail.com", password: "jeet234")
      expect(user).to_not be_valid
    end

    it "is invalid without an email" do
      user = User.new(username: "jeet", email: nil, password: "jeet123")
      expect(user).to_not be_valid
    end

    it "is invalid without a password" do
      user = User.new(username: "jeet", email: "jeet@gmail.com", password: nil)
      expect(user).to_not be_valid
    end

    it "is invalid with a duplicate email" do
      create(:user, email: "jeet@gmail.com")
      user = User.new(username: "jeet", email: "jeet@gmail.com", password: "jeet123")
      expect(user).to_not be_valid
    end
  end
end
