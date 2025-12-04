class AddNumQuestionsToParagraphs < ActiveRecord::Migration[8.0]
  def change
    add_column :paragraphs, :num_questions, :integer, default: 5, null: false
  end
end
