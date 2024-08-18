require "test_helper"

class PartnershipsControllerTest < ActionDispatch::IntegrationTest
  test "should get destroy" do
    get partnerships_destroy_url
    assert_response :success
  end
end
