class RemoveAnswerFromQuestions < ActiveRecord::Migration[7.0]
  def change
    remove_column :questions, :answer, :text
  end
end
