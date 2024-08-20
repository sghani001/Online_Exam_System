class StudentAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :question
  belongs_to :exam


  validates :user, presence: true
  validates :question, presence: true
  
end
