class AddCancelledToExams < ActiveRecord::Migration[7.0]
  def change
    add_column :exams, :cancelled, :boolean
  end
end
