require "test_helper"

class BreakRoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)      # test/fixtures/projects.yml から1件取得
    @break_room = break_rooms(:one) # test/fixtures/break_rooms.yml がある前提
  end

  test "should get index" do
    get project_break_rooms_url(@project)
    assert_response :success
  end

  test "should get new" do
    get new_project_break_room_url(@project)
    assert_response :success
  end

  test "should get edit" do
    get edit_project_break_room_url(@project, @break_room)
    assert_response :success
  end
end
