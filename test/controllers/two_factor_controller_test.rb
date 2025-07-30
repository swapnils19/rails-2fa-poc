require "test_helper"

class TwoFactorControllerTest < ActionDispatch::IntegrationTest
  test "should get setup" do
    get two_factor_setup_url
    assert_response :success
  end

  test "should get verify" do
    get two_factor_verify_url
    assert_response :success
  end

  test "should get disable" do
    get two_factor_disable_url
    assert_response :success
  end
end
