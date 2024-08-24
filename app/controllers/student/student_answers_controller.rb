module Student
  class StudentAnswersController < ApplicationController
    def create
      @exam = Exam.find(params[:exam_id])
      
      if params[:student_answers].present?
        params[:student_answers].each do |question_id, answer|
          StudentAnswer.create(
            user_id: current_user.id,
            question_id: question_id,
            exam_id: @exam.id,
            answer: answer
          )
        end
        redirect_to student_exams_path, notice: 'Your answers have been submitted.'
      else
        redirect_to student_exams_path, alert: 'No answers were submitted.'
      end
    end
  end
  
end