class AddDescriptionToExams < ActiveRecord::Migration[7.0]
  def change
    add_column :exams, :description, :text
  end
end
