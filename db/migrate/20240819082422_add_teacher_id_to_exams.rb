class AddTeacherIdToExams < ActiveRecord::Migration[7.0]
  def change
    add_column :exams, :teacher_id, :integer
  end
end
