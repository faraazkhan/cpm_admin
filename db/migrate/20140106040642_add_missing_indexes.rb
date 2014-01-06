class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :users, :role_id
    add_index :users, :client_id
    add_index :domains, :client_id
  end
end
