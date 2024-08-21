class AddRequestApprovalToExams < ActiveRecord::Migration[7.0]
  def change
    add_column :exams, :request_approval, :boolean
  end
end
