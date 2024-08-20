class AddExamIdToStudentAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :student_answers, :exam_id, :integer, null: false, foreign_key: true
  end
end
