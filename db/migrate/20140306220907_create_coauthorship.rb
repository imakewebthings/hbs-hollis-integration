class CreateCoauthorship < ActiveRecord::Migration
  def change
    create_table :coauthorships do |t|
      t.integer :author_id, null: false
      t.integer :coauthor_id, null: false
    end

    add_index :coauthorships, :author_id
    add_index :coauthorships, [:author_id, :coauthor_id], unique: true
  end
end
