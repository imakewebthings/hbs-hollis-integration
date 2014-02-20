class AddLcshToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :lcsh, :string
  end
end
