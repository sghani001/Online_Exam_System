class AddColumnToStudentAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :student_answers, :question_type, :string
    add_column :student_answers, :selected_option, :string
  end
end
