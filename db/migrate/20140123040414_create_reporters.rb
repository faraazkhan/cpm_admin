class CreateReporters < ActiveRecord::Migration
  def change
    create_table :reporters do |t|
      t.string :name
      t.string :ip
      t.integer :port
      t.string :login
      t.string :password
      t.string :database_name
      t.integer :load_group

      t.timestamps
    end
  end
end
