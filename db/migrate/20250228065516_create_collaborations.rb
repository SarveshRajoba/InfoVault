class CreateCollaborations < ActiveRecord::Migration[8.0]
  def change
    create_table :collaborations do |t|
      t.references :subject, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.bigint :owner_id, null: false
      t.string :status, null: false 
      t.string :access_level, null: false
      
      t.timestamps
    end
  end
end
