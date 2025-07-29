FactoryBot.define do
  factory :paragraph do
    sequence(:title) { |n| "Paragraph Title #{n}" }
    content { "This is sample content for the paragraph." }
    association :chapter
    association :user
  end
end