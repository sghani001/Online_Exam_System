class Exam < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :exam_outcomes
  has_many :student_answers, through: :questions
  belongs_to :teacher, class_name: 'User', foreign_key: 'teacher_id'
  validate :end_time_after_start_time
  

  def active?
  
    start_time <= Time.current.in_time_zone('Asia/Karachi') && end_time >= Time.current.in_time_zone('Asia/Karachi')
  end



  private

  def end_time_after_start_time
    if start_time.present? && end_time.present?
      if end_time.in_time_zone('Asia/Karachi') <= start_time.in_time_zone('Asia/Karachi')
        errors.add(:end_time, 'must be after start time')
      end
    end
  end

  validates :title, presence: true
  validates :description, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
end
