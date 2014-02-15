class CreateServiceGroups < ActiveRecord::Migration
  def change
    create_table :service_groups do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
