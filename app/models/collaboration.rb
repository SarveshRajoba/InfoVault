class Collaboration < ApplicationRecord
  belongs_to :subject
  belongs_to :user
  belongs_to :owner, class_name: "User"

  validates :status, inclusion: { in: %w[pending accepted rejected] }, presence: true
  validates :access_level, inclusion: { in: %w[read_only edit] }, presence: true
  validates :subject, presence: true
  validates :owner_id, presence: true
  validates :user, presence: true
end