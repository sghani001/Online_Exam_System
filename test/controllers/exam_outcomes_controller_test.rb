require "test_helper"

class ExamOutcomesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get exam_outcomes_index_url
    assert_response :success
  end

  test "should get show" do
    get exam_outcomes_show_url
    assert_response :success
  end

  test "should get new" do
    get exam_outcomes_new_url
    assert_response :success
  end

  test "should get create" do
    get exam_outcomes_create_url
    assert_response :success
  end
end
