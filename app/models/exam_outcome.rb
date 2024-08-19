class ExamOutcome < ApplicationRecord
  belongs_to :student, class_name: 'User'
  belongs_to :exam
end
