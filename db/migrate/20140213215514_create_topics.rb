class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name
      t.string :slug
      t.integer :record_count
    end

    add_index :topics, :record_count
    add_index :topics, :slug, unique: true
  end
end
