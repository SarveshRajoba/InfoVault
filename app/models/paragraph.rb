class Paragraph < ApplicationRecord
  before_save :format_and_sanitize_content

  belongs_to :chapter
  belongs_to :user
  
  has_many :questions, dependent: :destroy
  
  validates :chapter, presence: true
  validates :user, presence: true
  validates :title, presence: true, length: {maximum: 40}
  validates :content, presence: true
  validates :num_questions, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 20 }

  private

  def format_and_sanitize_content
    # First, convert plain text newlines to HTML if the content doesn't contain HTML tags
    if !content.match?(/<\w+>/)
      # Content appears to be plain text, convert newlines to HTML
      self.content = convert_plain_text_to_html(content)
    end
    
    # Then sanitize to keep only allowed HTML tags
    self.content = ActionController::Base.helpers.sanitize(
      content,
      tags: %w(p br strong em ul ol li h1 h2 h3 h4 h5 h6 code pre blockquote),
      attributes: %w(id class)
    )
  end

  def convert_plain_text_to_html(text)
    # Split by double newlines for paragraphs, then handle single newlines as line breaks
    paragraphs = text.split(/\n\n+/)
    
    html_paragraphs = paragraphs.map do |para|
      # Replace single newlines with <br> tags within a paragraph
      formatted_para = para.gsub(/\n/, '<br>')
      "<p>#{formatted_para}</p>"
    end
    
    html_paragraphs.join("\n")
  end

end