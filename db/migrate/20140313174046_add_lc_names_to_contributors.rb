class AddLcNamesToContributors < ActiveRecord::Migration
  def change
    add_column :contributors, :lc_names, :string
  end
end
