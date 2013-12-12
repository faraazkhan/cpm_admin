class RemoveDisabledFromAndAddStatusToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :disabled
    add_column :users, :status, :string
  end

end
