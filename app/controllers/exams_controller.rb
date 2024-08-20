class ExamsController < ApplicationController

  before_action :set_exam, only: [:show, :edit, :update, :destroy, :approve, :cancel, :take, :next_question]


  def take
      @current_question_index = params[:index].to_i || 0

      if @exam && @exam.questions.any?
        @question = @exam.questions.order(:id).offset(@current_question_index).limit(1).first

        if @question.nil?
          redirect_to exam_path(@exam), notice: 'No questions available for this exam.'
        end
      else
        redirect_to exam_path(@exam), notice: 'This exam has no questions.'
      end
  end


  
  

  def next_question
    @exam = Exam.find(params[:id])
    @current_question_index = params[:index].to_i
  
    # Validate the answer
    if params[:student_answer].blank?
      flash[:alert] = 'Please provide an answer before proceeding to the next question.'
      redirect_to take_exam_exam_path(@exam, index: @current_question_index)
      return
    end
  
    # Save the answer
    StudentAnswer.create(
      user_id: current_user.id,
      question_id: params[:question_id],
      answer: params[:student_answer],
      exam_id: @exam.id
    )
  
    # Move to the next question
    @current_question_index += 1
    @question = @exam.questions.order(:id).offset(@current_question_index).first
  
    if @question.nil?
      redirect_to exam_path(@exam), notice: 'You have completed the exam.'
    else
      redirect_to take_exam_exam_path(@exam, index: @current_question_index)
    end
  end
  
  
  

  def approve
    @exam.update(approved: true)
    redirect_to exams_path, notice: 'Exam was successfully approved.'
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
    if @exam.start_time > Time.now
      @exam.update(cancelled: true)
      redirect_to exams_path, notice: 'Exam was successfully cancelled.'
    else
      redirect_to exams_path, alert: 'Cannot cancel exam after it has started.'
    end
  end

  def destroy
    @exam.destroy

    redirect_to exams_path, notice: 'Exam was successfully destroyed.'
  end

  private

  def set_exam
    @exam = Exam.find(params[:id])
  end

  def exam_params
    params.require(:exam).permit(:title,:subject, :description, :start_time, :end_time)
  end

end
