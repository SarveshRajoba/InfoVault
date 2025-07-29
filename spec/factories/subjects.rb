FactoryBot.define do
  factory :subject do
    name { "Math" } 
    association :user
  end
end