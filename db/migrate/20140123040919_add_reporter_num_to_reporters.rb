class AddReporterNumToReporters < ActiveRecord::Migration
  def change
    add_column :reporters, :reporter_num, :integer
  end
end
