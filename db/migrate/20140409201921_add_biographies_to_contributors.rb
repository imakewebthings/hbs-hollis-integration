class AddBiographiesToContributors < ActiveRecord::Migration
  def change
    add_column :contributors, :brief_biography, :text
    add_column :contributors, :full_biography, :text
  end
end
