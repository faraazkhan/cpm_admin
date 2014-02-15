class AddServiceGroupIdToServices < ActiveRecord::Migration
  def change
    add_column :services, :service_group_id, :integer
  end
end
