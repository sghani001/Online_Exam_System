module Admin
  class QuestionsController < ApplicationController
    before_action :set_exam, only: [:show, :edit, :update, :destroy]
    before_action :set_question, only: [:show, :edit, :update, :destroy]
  
  
    def show
      @question = Question.find(params[:id])
      @exam = @question.exam
    end
  
    def edit
      @question = @exam.questions.find(params[:id])

    end
  
    def update
      if @question.update(question_params)
        redirect_to admin_exam_question_path(@exam, @question), notice: 'Question was successfully updated.'
      else
        render 'admin/questions/edit'
      end
    end
  
    def destroy
      @question.destroy
      redirect_to admin_exam_path(@exam), notice: 'Question was successfully destroyed.'
    end
  
    private
  
    def set_exam
      @exam = Exam.find(params[:exam_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_exams_path, alert: "Exam not found."
    end
  
    def set_question
      @question = @exam.questions.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_exam_path(@exam), alert: "Question not found."
    end
  
  
    def question_params
      params.require(:question).permit(:content, :question_type, options: {})
    end
  end
  
end