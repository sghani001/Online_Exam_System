require "test_helper"

class AutoSubmitTest < ApplicationSystemTestCase
  setup do
    # Create a teacher and student
    @teacher = User.create!(email: 'teacher@example.com', password: 'password', name: 'Teacher', user_type: 'teacher')
    @student = User.create!(email: 'student@example.com', password: 'password', name: 'Student', user_type: 'student')

    # Create an exam that already ended
    @exam = Exam.create!(title: 'AutoSubmit Exam', subject: 'Math', start_time: 2.hours.ago, end_time: 1.minute.ago, approved: true, cancelled: false, teacher_id: @teacher.id)

    # Add a question with a correct answer
    @question = @exam.questions.create!(content: 'What is 2+2?', question_type: 'short_answer', correct_answer: '4')

    # Student answered correctly before auto-submit
    StudentAnswer.create!(user_id: @student.id, question_id: @question.id, answer: '4', exam_id: @exam.id)
  end

  test "auto-submit grades and creates outcome" do
    # Ensure no outcome exists yet
    assert_nil ExamOutcome.find_by(student_id: @student.id, exam_id: @exam.id)

    # Run the auto-submit job
    AutoSubmitExamsJob.perform_now

    # Outcome should be created and graded
    outcome = ExamOutcome.find_by(student_id: @student.id, exam_id: @exam.id)
    assert_not_nil outcome, "Expected ExamOutcome to be created"
    assert_equal 1, outcome.score, "Expected score 1 for correct short_answer"

    # StudentAnswer marks should be set
    sa = StudentAnswer.find_by(user_id: @student.id, question_id: @question.id)
    assert_not_nil sa
    assert_equal 1.0, sa.marks
  end
end
