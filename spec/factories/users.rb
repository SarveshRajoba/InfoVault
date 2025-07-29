FactoryBot.define do
  factory :user do
    sequence(:username) {|n| "user#{n}" }
    sequence(:email) {|n| "user#{n}@gmail.com" }
    password {"123456789"}
  end
end