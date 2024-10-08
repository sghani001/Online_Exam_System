module Teacher
  class ExamsController < ApplicationController

    before_action :set_exam, only: [:show, :edit, :update, :destroy, :cancel, :request_approval, :review_exam, :assign_marks]
  
    

    
    def taken_exams
      @reviewed_exams = StudentAnswer.joins(:exam, :user)
                                     .where(exams: { teacher_id: current_user.id }, reviewed: true)
                                     .select('DISTINCT exams.id AS exam_id, exams.title AS exam_title, users.name AS student_name')
    
      @unreviewed_exams = StudentAnswer.joins(:exam, :user)
                                       .where(exams: { teacher_id: current_user.id }, reviewed: false)
                                       .select('DISTINCT exams.id AS exam_id, exams.title AS exam_title, users.name AS student_name')
    end
    
    

    def review_exam
      @students = User.where(id: StudentAnswer.where(exam_id: @exam.id).select(:user_id).distinct)
    end
  
    def assign_marks
      @exam = Exam.find(params[:id])
      @students = User.where(id: StudentAnswer.where(exam_id: @exam.id).select(:user_id).distinct)
    
      @students.each do |student|
        total_marks = 0
    
        StudentAnswer.where(exam_id: @exam.id, user_id: student.id).each do |answer|
          marks = params[:marks][answer.question_id.to_s].to_i
          answer.update(marks: marks, reviewed: true)
          total_marks += marks
        end
    
        exam_outcome = ExamOutcome.find_or_create_by(student_id: student.id, exam_id: @exam.id)
    
        Rails.logger.debug "Student ID: #{student.id}, Total Marks: #{total_marks}, ExamOutcome ID: #{exam_outcome.id}"
    
        if exam_outcome.update(score: total_marks)
          Rails.logger.debug "ExamOutcome updated successfully for Student ID: #{student.id} with Total Marks: #{total_marks}"
        else
          Rails.logger.error "Failed to update ExamOutcome for Student ID: #{student.id}. Errors: #{exam_outcome.errors.full_messages.join(', ')}"
        end
      end
    
      redirect_to taken_exams_teacher_exams_path, notice: 'Marks assigned successfully'
    end
    
    
    
    
    
    def index
      @exams = Exam.all
    end
  
    def show
    end
  
    def new
      @exam = Exam.new
    end
  
    def create  
      @exam = Exam.new(exam_params)
      @exam.teacher = current_user
      if @exam.save
        redirect_to teacher_exam_path(@exam), notice: 'Exam was successfully created.'
      else
        redirect_to new_teacher_exam_path, alert: 'Exam could not be created.'
      end
    end
  
  
    def edit
      if @exam.start_time < Time.now
        redirect_to teacher_exams_path, alert: 'Cannot edit exam after it has started.'
      end
    end
  
    def update
      if @exam.update(exam_params)
        redirect_to teacher_exam_path(@exam), notice: 'Exam was successfully updated.'
      else
        render :edit
      end
    end
  
  
    def cancel
      if @exam.start_time > Time.now || !@exam.approved
        @exam.update(cancelled: true)
        redirect_to teacher_exams_path, notice: 'Exam was successfully cancelled.'
      elsif @exam.end_time < Time.now
        redirect_to teacher_exams_path, alert: 'Cannot cancel exam after it has ended.'
      else
        redirect_to teacher_exams_path, alert: 'Cannot cancel exam after it has started.'
      end
    end
  
    def request_approval
      if @exam.cancelled
        redirect_to teacher_exams_path, alert: 'Cannot request approval for a cancelled exam.'
      elsif @exam.approved
        redirect_to teacher_exams_path, alert: 'Exam is already approved.'
      elsif @exam.start_time < Time.now && @exam.end_time < Time.now
        redirect_to teacher_exams_path, alert: 'Cannot Request approval for an exam that has ended.'
      else
        @exam.update(request_approval: true)
        redirect_to teacher_exams_path, notice: 'Exam approval requested.'
      end
    end
  
    def destroy
      @exam.destroy
  
      redirect_to teacher_exams_path, notice: 'Exam was successfully Deleted.'
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