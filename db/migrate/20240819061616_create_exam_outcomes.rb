class CreateExamOutcomes < ActiveRecord::Migration[7.0]
  def change
    create_table :exam_outcomes do |t|
      t.references :student, null: false, foreign_key: true
      t.references :exam, null: false, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end
