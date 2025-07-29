class Paragraph < ApplicationRecord
  before_save :sanitize_content

  belongs_to :chapter
  belongs_to :user
  
  has_many :questions, dependent: :destroy
  
  validates :chapter, presence: true
  validates :user, presence: true
  validates :title, presence: true, length: {maximum: 40}
  validates :content, presence: true

  private

  def sanitize_content
    self.content = ActionController::Base.helpers.sanitize(
      content,
      tags: %w(p br strong em ul ol li),
      attributes: %w(id class)
    )
  end

end