class AddOptionsToQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :options, :jsonb, default: {}
    add_column :questions, :answer, :text
  end
end
