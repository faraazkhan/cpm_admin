class CreateClientServicesTable < ActiveRecord::Migration
  def change
    create_table :clients_services, :id => false do |t|
      t.references :client
      t.references :service
    end
     add_index :clients_services, [:client_id, :service_id]
     add_index :clients_services, :client_id
  end
end
