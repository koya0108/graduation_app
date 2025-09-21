require "test_helper"

class BreakRoomsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get break_rooms_index_url
    assert_response :success
  end

  test "should get edit" do
    get break_rooms_edit_url
    assert_response :success
  end

  test "should get new" do
    get break_rooms_new_url
    assert_response :success
  end
end
