class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    case user.user_type
    when 'Admin'
      can :manage, :all
    when 'Teacher'
      can :manage, Exam
      can :read, ExamOutcome
      cannot :approve, Exam
    when 'Student'
      can :read, Exam
      can :create, ExamOutcome
    end
  end
end
