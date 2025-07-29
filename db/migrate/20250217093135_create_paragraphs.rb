class CreateParagraphs < ActiveRecord::Migration[8.0]
  def change
    create_table :paragraphs do |t|
      t.references :chapter, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
