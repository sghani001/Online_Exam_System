class ExamsController < ApplicationController

  before_action :set_exam, only: [:show, :edit, :update, :destroy, :approve, :cancel, :take, :next_question, :request_approval]


  def take
      @current_question_index = params[:index].to_i || 0

      if StudentAnswer.exists?(user_id: current_user.id, exam_id: @exam.id)
        redirect_to exams_path, notice: 'You have already attempted this exam.'
        return
      end 

      if @exam && @exam.questions.any?
        @question = @exam.questions.order(:id).offset(@current_question_index).limit(1).first

        if @question.nil?
          redirect_to exams_path, notice: 'No questions available for this exam.'
        end
      else
        redirect_to exams_path, notice: 'This exam has no questions.'
      end
  end


  
  

  def next_question   
    @current_question_index = params[:index].to_i
  
    if params[:student_answer].blank?
      flash[:alert] = 'Please provide an answer before proceeding to the next question.'
      redirect_to take_exam_path(@exam, index: @current_question_index)
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
  
    
  end
  
  
  

  def approve
    if @exam.questions.exists?
      @exam.update(approved: true)
      redirect_to exams_path, notice: 'Exam was successfully approved.'
    else
      redirect_to exams_path, alert: 'Exam cannot be approved without any questions.'
    end
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
      redirect_to @exam, notice: 'Exam was successfully created.'
    else
      render :new
    end
  end


  def edit
    if @exam.start_time < Time.now
      redirect_to exams_path, alert: 'Cannot edit exam after it has started.'
    end
  end

  def update
    if @exam.update(exam_params)
      redirect_to @exam, notice: 'Exam was successfully updated.'
    else
      render :edit
    end
  end


  def cancel
    if @exam.start_time > Time.now || !@exam.approved
      @exam.update(cancelled: true)
      redirect_to exams_path, notice: 'Exam was successfully cancelled.'
    elsif @exam.end_time < Time.now
      redirect_to exams_path, alert: 'Cannot cancel exam after it has ended.'
    else
      redirect_to exams_path, alert: 'Cannot cancel exam after it has started.'
    end
  end

  def request_approval
    if @exam.cancelled
      redirect_to exams_path, alert: 'Cannot request approval for a cancelled exam.'
    else
      @exam.update(request_approval: true)
      redirect_to exams_path, notice: 'Exam approval requested.'
    end
  end

  def destroy
    @exam.destroy

    redirect_to exams_path, notice: 'Exam was successfully Deleted.'
  end

  private

  def set_exam
    @exam = Exam.find(params[:id])
  end

  def exam_params
    params.require(:exam).permit(:title,:subject, :description, :start_time, :end_time)
  end

end
