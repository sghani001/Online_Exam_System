class Question < ApplicationRecord
  belongs_to :exam
  serialize :options, Hash

  validates :content, presence: true
  validates :question_type, inclusion: { in: %w[multiple_choice short_answer] }
  validate :validate_options_for_multiple_choice

  private

  def validate_options_for_multiple_choice
    if question_type == 'multiple_choice' && options.keys.size != 3
      errors.add(:options, "must have exactly three options")
    end
  end
end
