class AddMarksToStudentAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :student_answers, :marks, :float
  end
end
