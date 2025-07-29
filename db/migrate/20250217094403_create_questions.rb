class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.references :paragraph, null: false, foreign_key: true
      t.text :question, null: false
      
      t.timestamps
    end
  end
end
