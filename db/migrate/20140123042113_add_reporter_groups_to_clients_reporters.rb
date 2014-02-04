class AddReporterGroupsToClientsReporters < ActiveRecord::Migration
  def change
    add_column :clients_reporters, :reporter_group_cpm, :string
    add_column :clients_reporters, :reporter_group_vmw, :string
    add_column :clients_reporters, :reporter_group_sql, :string
    add_column :clients_reporters, :reporter_group_ora, :string
  end
end
