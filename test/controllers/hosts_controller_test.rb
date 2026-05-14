require "test_helper"

class HostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @profile = host_profiles(:active_profile)
    @host    = @profile.user
  end

  # ── 200 / 404 ─────────────────────────────────────────────────────────────

  test "GET /h/:slug returns 200 for active host" do
    get host_page_path(@profile.slug)
    assert_response :success
  end

  test "GET /h/:slug returns 404 for unknown slug" do
    get host_page_path("does-not-exist")
    assert_response :not_found
  end

  test "GET /h/:slug returns 404 for deactivated host" do
    deactivated = host_profiles(:deactivated_profile)
    get host_page_path(deactivated.slug)
    assert_response :not_found
  end

  # ── Story panel ───────────────────────────────────────────────────────────

  test "story panel renders when host_story is present" do
    @profile.update!(host_story: "Started Sunday jams three years ago.")
    get host_page_path(@profile.slug)
    assert_response :success
    assert_select "p", text: /Started Sunday jams three years ago/
    assert_select "p", text: /Meet your host/i
  end

  test "story panel is absent when host_story is blank" do
    @profile.update!(host_story: nil)
    get host_page_path(@profile.slug)
    assert_response :success
    assert_select "p", text: /Meet your host/i, count: 0
  end

  # ── No auth required ──────────────────────────────────────────────────────

  test "page is publicly accessible without sign-in" do
    get host_page_path(@profile.slug)
    assert_response :success
  end
end
