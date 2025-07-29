class Answer < ApplicationRecord
  belongs_to :question

  validates :question, presence: true
  validates :answer, presence: true
end