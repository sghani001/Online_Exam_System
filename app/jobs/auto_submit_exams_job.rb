class AutoSubmitExamsJob < ApplicationJob
  queue_as :default

  def perform
    now = Time.current

    exams = Exam.where('end_time <= ? AND cancelled = ? AND approved = ?', now, false, true)

    exams.find_each do |exam|
      # find users who have at least one answer for this exam (started)
      user_ids = StudentAnswer.where(exam_id: exam.id).distinct.pluck(:user_id)

      user_ids.each do |uid|
        user = User.find_by(id: uid)
        next unless user

        # Skip if outcome already exists (already submitted/graded)
        next if ExamOutcome.exists?(student_id: user.id, exam_id: exam.id)

        # Track auto-submission
        begin
          PersonaEvent.create!(trackable: exam, action: 'exam_auto_submitted', metadata: { user_id: user.id }) if defined?(PersonaEvent)
        rescue => e
          Rails.logger.debug "Persona event failed: #{e.message}"
        end

        # Grade using existing service
        begin
          total = ExamGrader.grade(exam, user)
          Rails.logger.info "Auto-graded exam #{exam.id} for user #{user.id} => score: #{total}"
        rescue => e
          Rails.logger.error "Auto grading failed for exam #{exam.id} user #{user.id}: #{e.message}"
        end

        # Broadcast updated progress to instructor stream
        begin
          Turbo::StreamsChannel.broadcast_replace_to(
            "exam_#{exam.id}",
            target: "student_progress_#{user.id}_#{exam.id}",
            partial: 'teacher/exams/student_progress',
            locals: { user: user, exam: exam, current_question_index: exam.questions.count, total_questions: exam.questions.count }
          )
        rescue => e
          Rails.logger.debug "Broadcast failed: #{e.message}"
        end
      end
      
      # Also ensure students who never started receive an outcome (score 0)
      student_ids = User.where(user_type: 'student').pluck(:id)
      not_started = student_ids - user_ids

      not_started.each do |sid|
        # Skip if an outcome already exists
        next if ExamOutcome.exists?(student_id: sid, exam_id: exam.id)

        # Create zero-score outcome
        begin
          ExamOutcome.create!(student_id: sid, exam_id: exam.id, score: 0)
          Rails.logger.info "Created zero-score ExamOutcome for exam #{exam.id} user #{sid}"
        rescue => e
          Rails.logger.error "Failed creating ExamOutcome for exam #{exam.id} user #{sid}: #{e.message}"
          next
        end

        # Broadcast to instructor stream for visibility
        begin
          user = User.find_by(id: sid)
          Turbo::StreamsChannel.broadcast_replace_to(
            "exam_#{exam.id}",
            target: "student_progress_#{sid}_#{exam.id}",
            partial: 'teacher/exams/student_progress',
            locals: { user: user, exam: exam, current_question_index: exam.questions.count, total_questions: exam.questions.count }
          )
        rescue => e
          Rails.logger.debug "Broadcast for zero-score outcome failed: #{e.message}"
        end
      end
    end
  end
end
