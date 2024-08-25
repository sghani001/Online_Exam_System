module Admin
  class ExamsController < ApplicationController

    before_action :set_exam, only: [:show, :edit, :update, :destroy, :approve, :cancel]
  
  
    
  
    def approve
      if @exam.questions.exists?
        @exam.update(approved: true)
        redirect_to admin_exams_path, notice: 'Exam was successfully approved.'
      else
        redirect_to admin_exams_path, alert: 'Exam cannot be approved without any questions.'
      end
    end
    
    def index
      @exams = Exam.all
    end
  
    def show
    end
  
    
  
    def edit
      if @exam.start_time < Time.now && @exam.end_time > Time.now
        redirect_to admin_exams_path, alert: 'Cannot edit exam after it has started.'
      elsif @exam.end_time < Time.now
        redirect_to admin_exams_path, alert: 'Cannot edit exam after it has ended.'
      end
    end
  
    def update
      if @exam.update(exam_params)
        redirect_to admin_exam_path(@exam), notice: 'Exam was successfully updated.'
      else
        render :edit
      end
    end
  
  
    def cancel
      if @exam.start_time > Time.now || !@exam.approved
        @exam.update(cancelled: true)
        redirect_to admin_exams_path, notice: 'Exam was successfully cancelled.'
      elsif @exam.end_time < Time.now
        redirect_to admin_exams_path, alert: 'Cannot cancel exam after it has ended.'
      else
        redirect_to admin_exams_path, alert: 'Cannot cancel exam after it has started.'
      end
    end

    def reviewed_exams
      @reviewed_exams = Exam.joins(:student_answers)
                            .where(student_answers: { reviewed: true })
                            .select('Distinct exams.*, student_answers.user_id as student_id')
    end
    
    
  
  
    def destroy
    @exam.destroy
  
      redirect_to admin_exams_path, notice: 'Exam was successfully Deleted.'
    end
  
    private
  
    def set_exam
      @exam = Exam.find(params[:id])
    end
  
    def exam_params
      params.require(:exam).permit(:title,:subject, :description, :start_time, :end_time)
    end
  
  end
  
end