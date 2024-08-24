class AddReviewedToExams < ActiveRecord::Migration[7.0]
  def change
    add_column :exams, :reviewed, :boolean, default: false
  end
end
