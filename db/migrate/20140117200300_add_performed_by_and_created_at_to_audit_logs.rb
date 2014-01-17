class AddPerformedByAndCreatedAtToAuditLogs < ActiveRecord::Migration
  def change
    add_column :audit_logs, :performed_by, :integer
    add_column :audit_logs, :created_at, :datetime
  end
end
