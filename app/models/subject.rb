class Subject < ApplicationRecord
  belongs_to :user
  has_many :chapters, dependent: :destroy
  
  has_many :collaborations, dependent: :destroy
  has_many :collaborators, through: :collaborations, source: :user

  validates :name, presence: true
  validates :user, presence: true
end