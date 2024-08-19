class Exam < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :exam_outcomes
  belongs_to :teacher, class_name: 'User', foreign_key: 'teacher_id'

  def active?
    start_time <= Time.current && end_time >= Time.current
  end

  validates :title, presence: true
  validates :description, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
end
