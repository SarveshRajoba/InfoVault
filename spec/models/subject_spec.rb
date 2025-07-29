require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe "Validations" do
    it "is valid with a name and user" do
      user = create(:user)
      subject = Subject.new(name: "Math", user: user)
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      user = create(:user)
      subject = Subject.new(name: nil, user: user)
      expect(subject).to_not be_valid
    end
    
    it "is invalid without a user" do
      subject = Subject.new(name: "Math")
      expect(subject).to_not be_valid
    end
  end
end