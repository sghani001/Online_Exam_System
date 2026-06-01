class ExamGrader
  # Grades an exam for a user. Assumes each question is worth 1 mark.
  # Updates StudentAnswer.marks and creates/updates ExamOutcome.score
+  def self.grade(exam, user)
+    return unless exam && user
+
+    questions = exam.questions.order(:id)
+    answers = StudentAnswer.where(exam_id: exam.id, user_id: user.id).index_by(&:question_id)
+
+    total_marks = 0.0
+
+    questions.each do |q|
+      student_answer = answers[q.id]
+      awarded = 0.0
+
+      if student_answer.present?
+        if q.question_type == 'multiple_choice'
+          awarded = (student_answer.answer.to_s.strip == q.correct_answer.to_s.strip) ? 1.0 : 0.0
+        elsif q.question_type == 'short_answer'
+          # simple case-insensitive match; can be improved with NLP or regex
+          awarded = (student_answer.answer.to_s.strip.downcase == q.correct_answer.to_s.strip.downcase) ? 1.0 : 0.0
+        end
+
+        student_answer.update(marks: awarded)
+        total_marks += awarded
+      else
+        # unanswered question => zero marks
+      end
+    end
+
+    outcome = ExamOutcome.find_or_initialize_by(student_id: user.id, exam_id: exam.id)
+    outcome.score = total_marks
+    outcome.save!
+
+    total_marks
+  end
 end
