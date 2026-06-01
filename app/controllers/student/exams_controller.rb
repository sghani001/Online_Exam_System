module Student
  class ExamsController < ApplicationController

    before_action :set_exam, only: [:show, :take, :next_question, :review_student_exam, :submit]
    before_action :check_exam_active, only: [:take, :next_question]
  
  
    def take
      @current_question_index = params[:index].to_i || 0
    
      if all_questions_answered?
        redirect_to student_exams_path, notice: 'You have already attempted this exam.'
        return
      end
    
      if @exam && @exam.questions.any?
        @question = @exam.questions.order(:id).offset(@current_question_index).limit(1).first

        # Track that the student started or resumed this exam
        if current_user
          persona_track(:exam_started, { exam_id: @exam.id, user_id: current_user.id, index: @current_question_index })
        end
    
        if @question.nil?
          redirect_to student_exams_path, notice: 'No questions available for this exam.'
          return
        end

        # Broadcast initial progress/timer to this student's stream
        if current_user
          stream_name = "exam_#{@exam.id}_user_#{current_user.id}"
          Turbo::StreamsChannel.broadcast_replace_to(
            stream_name,
            target: "exam_progress_#{current_user.id}_#{@exam.id}",
            partial: 'student/exams/exam_progress',
            locals: { current_question_index: @current_question_index, total_questions: @exam.questions.count, exam: @exam }
          )

          # Also notify exam-level stream for instructors
          Turbo::StreamsChannel.broadcast_replace_to(
            "exam_#{@exam.id}",
            target: "student_progress_#{current_user.id}_#{@exam.id}",
            partial: 'teacher/exams/student_progress',
            locals: { user: current_user, exam: @exam, current_question_index: @current_question_index, total_questions: @exam.questions.count }
          )
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
          # Record exam completion
          if current_user
            persona_track(:exam_completed, { exam_id: @exam.id, user_id: current_user.id })

          stream_name = "exam_#{@exam.id}_user_#{current_user.id}"
          Turbo::StreamsChannel.broadcast_replace_to(
            stream_name,
            target: "exam_progress_#{current_user.id}_#{@exam.id}",
            partial: 'student/exams/exam_progress',
            locals: { current_question_index: @exam.questions.count, total_questions: @exam.questions.count, exam: @exam }
          )

          Turbo::StreamsChannel.broadcast_replace_to(
            "exam_#{@exam.id}",
            target: "student_progress_#{current_user.id}_#{@exam.id}",
            partial: 'teacher/exams/student_progress',
            locals: { user: current_user, exam: @exam, current_question_index: @exam.questions.count, total_questions: @exam.questions.count }
          )
          end

          redirect_to student_exams_path, notice: 'You have completed the exam.'
      else
        redirect_to take_student_exam_path(@exam, index: @current_question_index)
        # Broadcast updated progress for next question
        if current_user
          stream_name = "exam_#{@exam.id}_user_#{current_user.id}"
          Turbo::StreamsChannel.broadcast_replace_to(
            stream_name,
            target: "exam_progress_#{current_user.id}_#{@exam.id}",
            partial: 'student/exams/exam_progress',
            locals: { current_question_index: @current_question_index, total_questions: @exam.questions.count, exam: @exam }
          )

          Turbo::StreamsChannel.broadcast_replace_to(
            "exam_#{@exam.id}",
            target: "student_progress_#{current_user.id}_#{@exam.id}",
            partial: 'teacher/exams/student_progress',
            locals: { user: current_user, exam: @exam, current_question_index: @current_question_index, total_questions: @exam.questions.count }
          )
        end
      end
    end

    def submit
      # Finalize exam for current_user
      if current_user
        persona_track(:exam_submitted, { exam_id: @exam.id, user_id: current_user.id })

        # Auto-grade the exam and update ExamOutcome
        begin
          total = ExamGrader.grade(@exam, current_user)
          Rails.logger.info "Auto-graded exam #{@exam.id} for user #{current_user.id} => score: #{total}"
        rescue => e
          Rails.logger.error "Exam grading failed: #{e.message}"
        end

        # Broadcast completion to student's stream and instructor stream
        stream_name = "exam_#{@exam.id}_user_#{current_user.id}"
        Turbo::StreamsChannel.broadcast_replace_to(
          stream_name,
          target: "exam_progress_#{current_user.id}_#{@exam.id}",
          partial: 'student/exams/exam_progress',
          locals: { current_question_index: @exam.questions.count, total_questions: @exam.questions.count, exam: @exam }
        )

        Turbo::StreamsChannel.broadcast_replace_to(
          "exam_#{@exam.id}",
          target: "student_progress_#{current_user.id}_#{@exam.id}",
          partial: 'teacher/exams/student_progress',
          locals: { user: current_user, exam: @exam, current_question_index: @exam.questions.count, total_questions: @exam.questions.count }
        )
      end

      redirect_to student_exams_path, notice: 'Exam submitted.'
    end
    
  
    
    def index
      @exams = Exam.all
      @taken_exams_ids = StudentAnswer.where(user_id: current_user.id).pluck(:exam_id).uniq
    
      @active_exams = @exams.select do |exam|
        exam.active? && !exam.cancelled && exam.approved? && !@taken_exams_ids.include?(exam.id)
      end
    
      @upcoming_exams = @exams.select do |exam|
        exam.start_time > Time.now && !exam.cancelled && exam.approved? && !@taken_exams_ids.include?(exam.id)
      end
    
      @missed_exams = @exams.select do |exam|
        exam.end_time < Time.now && !exam.cancelled && exam.approved? && !@taken_exams_ids.include?(exam.id)
      end
    
      @taken_exams_details = @exams.select { |exam| @taken_exams_ids.include?(exam.id) }
    end
    

    def review_student_exam
      @student_answers = StudentAnswer.where(user_id: current_user.id, exam_id: @exam.id)
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

    def check_exam_active
      return unless @exam && @exam.end_time
      if Time.now > @exam.end_time
        # Time expired; auto-submit for the user
        persona_track(:exam_auto_submitted, { exam_id: @exam.id, user_id: current_user.id }) if current_user
        redirect_to submit_student_exam_path(@exam), notice: 'Exam time expired and was submitted automatically.'
      end
    end
  
    def exam_params
      params.require(:exam).permit(:title,:subject, :description, :start_time, :end_time)
    end
  
  end
  
end