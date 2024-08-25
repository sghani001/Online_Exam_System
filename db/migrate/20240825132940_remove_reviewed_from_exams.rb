class RemoveReviewedFromExams < ActiveRecord::Migration[7.0]
  def change
    remove_column :exams, :reviewed, :boolean, default: false
    add_column :student_answers, :reviewed, :boolean, default: false
  end
end
