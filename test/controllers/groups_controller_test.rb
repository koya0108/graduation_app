require "test_helper"

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)   # test/fixtures/projects.yml から取得
    @group   = groups(:one)     # test/fixtures/groups.yml から取得
  end

  test "should get index" do
    get project_groups_url(@project)
    assert_response :success
  end

  test "should get new" do
    get new_project_group_url(@project)
    assert_response :success
  end

  test "should get edit" do
    get edit_project_group_url(@project, @group)
    assert_response :success
  end
end