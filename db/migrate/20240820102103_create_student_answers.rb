class CreateStudentAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :student_answers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.text :answer
      

      t.timestamps
    end
  end
end
