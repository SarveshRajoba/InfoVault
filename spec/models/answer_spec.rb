require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe "Validations" do
    let(:question) { create(:question) }

    it "is valid with valid attributes" do
      answer = build(:answer, question: question, answer: "This is a valid answer.")
      expect(answer).to be_valid
    end

    it "is invalid without an answer" do
      answer = build(:answer, answer: nil)
      expect(answer).to_not be_valid
      expect(answer.errors[:answer]).to include("can't be blank")
    end

    it "is invalid without a question" do
      answer = build(:answer, question: nil)
      expect(answer).to_not be_valid
      expect(answer.errors[:question]).to include("must exist")
    end
  end
end
