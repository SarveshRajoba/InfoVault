require 'rails_helper'

RSpec.describe Chapter, type: :model do
  describe "Validations" do
    it "is valid with a name and subject" do
      chapter = create(:chapter)
      expect(chapter).to be_valid
    end

    it "is invalid without a name" do
      chapter = build(:chapter, name: nil)
      expect(chapter).to_not be_valid
    end

    it "is invalid without a subject" do
      chapter = build(:chapter, subject: nil)
      expect(chapter).to_not be_valid
    end
  end
end
