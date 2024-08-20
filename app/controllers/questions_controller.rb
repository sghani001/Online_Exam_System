class QuestionsController < ApplicationController
  before_action :set_exam, only: [:new, :create, :show, :edit, :update, :destroy]
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  def new
    @question = @exam.questions.new
  end

  def create
    @question = @exam.questions.new(question_params)

    if @question.question_type == 'multiple_choice'
      @question.options = {
        params[:question][:option_1] => false,
        params[:question][:option_2] => false,
        params[:question][:option_3] => false
      }
    end

    if @question.save
      redirect_to exam_path(@exam), notice: 'Question was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end


  def show
    @question = Question.find(params[:id])
    @exam = @question.exam
  end

  def edit
    @question = @exam.questions.find(params[:id])
  end

  def update
    if @question.update(question_params)
      redirect_to exam_question_path(@exam, @question), notice: 'Question was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @question.destroy
    redirect_to exam_path(@exam), notice: 'Question was successfully destroyed.'
  end

  private

  def set_exam
    @exam = Exam.find(params[:exam_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to exams_path, alert: "Exam not found."
  end

  def set_question
    @question = @exam.questions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to exam_path(@exam), alert: "Question not found."
  end


  def question_params
    params.require(:question).permit(:content, :question_type, :answer, options: {})
  end
end
