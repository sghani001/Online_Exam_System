module Student
  class ExamsController < ApplicationController

    before_action :set_exam, only: [:show, :take, :next_question]
  
  
    def take
      @current_question_index = params[:index].to_i || 0
    
      if all_questions_answered?
        redirect_to student_exams_path, notice: 'You have already attempted this exam.'
        return
      end
    
      if @exam && @exam.questions.any?
        @question = @exam.questions.order(:id).offset(@current_question_index).limit(1).first
    
        if @question.nil?
          redirect_to student_exams_path, notice: 'No questions available for this exam.'
        end
      else
        redirect_to student_exams_path, notice: 'This exam has no questions.'
      end
    end
    
    
    
    
    
  
    def next_question
      @current_question_index = params[:index].to_i
      
      if params[:student_answer].blank?
        flash[:alert] = 'Please provide an answer before proceeding to the next question.'
        redirect_to take_student_exam_path(@exam, index: @current_question_index)
        return
      end
    
      StudentAnswer.create(
        user_id: current_user.id,
        question_id: params[:question_id],
        answer: params[:student_answer],
        exam_id: @exam.id
      )
    
      @current_question_index += 1
    
      @question = @exam.questions.order(:id).offset(@current_question_index).first
    
      if @question.nil?
        redirect_to student_exams_path, notice: 'You have completed the exam.'
      else
        redirect_to take_student_exam_path(@exam, index: @current_question_index)
      end
    end
    
  
    
    def index
      @exams = Exam.all
    end
  
    def show
    end
  
    private

    
    def all_questions_answered?
      question_ids = @exam.questions.pluck(:id)
      answered_question_ids = StudentAnswer.where(user_id: current_user.id, exam_id: @exam.id).pluck(:question_id)
      question_ids.sort == answered_question_ids.sort
    end
  
    def set_exam
      @exam = Exam.find(params[:id])
    end
  
    def exam_params
      params.require(:exam).permit(:title,:subject, :description, :start_time, :end_time)
    end
  
  end
  
end