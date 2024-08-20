class RemoveSelectedOptionFromStudentAnswers < ActiveRecord::Migration[7.0]
  def change
    remove_column :student_answers, :selected_option, :string
  end
end
