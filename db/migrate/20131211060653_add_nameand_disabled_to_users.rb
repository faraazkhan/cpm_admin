class AddNameandDisabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :disabled, :boolean
  end
end
