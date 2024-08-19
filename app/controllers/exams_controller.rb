class ExamsController < ApplicationController

  before_action :set_exam, only: [:show, :edit, :update, :destroy, :approve, :cancel]

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
