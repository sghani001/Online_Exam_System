class CreateExams < ActiveRecord::Migration[7.0]
  def change
    create_table :exams do |t|
      t.string :title
      t.string :subject
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :approved

      t.timestamps
    end
  end
end
