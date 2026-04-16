class CreateStoryCards < ActiveRecord::Migration[8.1]
  def change
    create_table :story_cards do |t|
      t.references :event, null: false, foreign_key: true
      t.string :card_type, null: false
      t.string :status, null: false, default: "pending"
      t.string :generated_image_url

      t.timestamps
    end

    add_index :story_cards, [ :event_id, :card_type ], unique: true
  end
end
