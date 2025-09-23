require "test_helper"

class ShiftDetailsControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get shift_details_update_url
    assert_response :success
  end
end
