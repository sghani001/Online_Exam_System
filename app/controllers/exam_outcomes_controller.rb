class ExamOutcomesController < ApplicationController
  before_action :admin_only

  def index
    @exam_outcomes = ExamOutcome.all
  end

  def show
    @exam_outcome = ExamOutcome.find(params[:id])
  end

  def new
  end

  def create
    @exam_outcome = current_user.exam_outcomes.build(exam_outcome_params)
    if @exam_outcome.save
      redirect_to exam_outcome_path(@exam_outcome), notice: 'Exam submitted successfully.'
    else
      render :new
    end
  end
end
