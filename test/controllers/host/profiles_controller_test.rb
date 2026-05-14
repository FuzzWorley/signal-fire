require "test_helper"

class Host::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = users(:host_user)
    post host_login_path, params: { email: @host.email, password: "password123" }
  end

  test "GET /host/profile renders edit form" do
    get host_profile_path
    assert_response :success
    assert_select "h1", text: /your host page/i
  end

  test "PATCH /host/profile updates display_name and blurb" do
    patch host_profile_path, params: {
      profile: { display_name: "New Name", blurb: "New bio" }
    }
    assert_redirected_to host_profile_path
    @host.host_profile.reload
    assert_equal "New Name", @host.host_profile.display_name
    assert_equal "New bio", @host.host_profile.blurb
  end

  test "PATCH /host/profile saves host_story" do
    patch host_profile_path, params: {
      profile: { host_story: "Started Sunday jams three years ago." }
    }
    assert_redirected_to host_profile_path
    assert_equal "Started Sunday jams three years ago.", @host.host_profile.reload.host_story
  end

  test "GET /host/profile edit form includes host_story field" do
    get host_profile_path
    assert_response :success
    assert_select "textarea[name='profile[host_story]']"
  end

  test "GET /host/profile redirects unauthenticated user" do
    delete host_logout_path
    get host_profile_path
    assert_redirected_to host_login_path
  end
end
