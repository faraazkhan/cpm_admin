class CreateEnvVars < ActiveRecord::Migration
  def change
    create_table :env_vars do |t|
      t.string :name
      t.string :value
      t.string :description

      t.timestamps
    end
  end
end
