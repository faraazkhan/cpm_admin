class AddAuditLog < ActiveRecord::Migration
  def change
    create_table :audit_logs do |t|
      t.string :item_type
      t.integer :item_id
      t.string :item_attribute
      t.string :previous_value
      t.string :new_value
    end
  end

end
