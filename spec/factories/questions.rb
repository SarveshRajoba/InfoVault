FactoryBot.define do
  factory :question do
    sequence(:question) { |n| "Question #{n}" }
    association :paragraph
  end
end
