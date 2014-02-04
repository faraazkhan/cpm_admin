class CreateClientsReportersTable < ActiveRecord::Migration
  def change
    create_table :clients_reporters do |t|
      t.integer :client_id
      t.integer  :reporter_id
      t.datetime :created_at
    end
  end

end
