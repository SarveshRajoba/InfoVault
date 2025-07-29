class Question < ApplicationRecord
  belongs_to :paragraph
  has_many :answers, dependent: :destroy

  validates :paragraph, presence: true
  validates :question, presence: true
end
