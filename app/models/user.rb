class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  enum user_type: { admin: 'Admin', teacher: 'Teacher', student: 'Student' }
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :exam_outcomes, foreign_key: :student_id
  has_many :exams, foreign_key: 'teacher_id'
  has_many :student_answers, dependent: :destroy
  validates :user_type, presence: true

  # Define role methods
  def admin?
    user_type == 'Admin'
  end

  def teacher?
    user_type == 'Teacher'
  end

  def student?
    user_type == 'Student'
  end
end
