FactoryBot.define do
  factory :chapter do
    name { "resonance" }
    association :subject
  end
end