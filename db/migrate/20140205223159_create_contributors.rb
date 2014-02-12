class CreateContributors < ActiveRecord::Migration
  def change
    create_table :contributors do |t|
      t.string :surname
      t.string :given_name
      t.string :role
      t.string :primary_unit
      t.integer :person_id
      t.string :title
      t.string :name_slug
      t.string :primary_unit_slug
    end

    add_index :contributors, :surname
    add_index :contributors, :primary_unit
    add_index :contributors, :person_id, unique: true
    add_index :contributors, :name_slug
    add_index :contributors, :primary_unit_slug
  end
end
