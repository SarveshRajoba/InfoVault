FactoryBot.define do
  factory :answer do
    answer {"answer"}
    association :question
  end
end
