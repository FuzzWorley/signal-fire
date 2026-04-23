require "test_helper"

class Api::V1::EmailCapturesControllerTest < ActionDispatch::IntegrationTest
  test "POST tracks empty_totem_email_captured with totem_id and email" do
    totem = totems(:secondary_totem)
    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post api_v1_totem_email_captures_path(totem_slug: totem.slug),
           params: { email: "new@example.com" },
           as: :json
    end
    assert_equal 1, tracked.size
    assert_equal "empty_totem_email_captured", tracked.first[0]
    assert_equal totem.id,          tracked.first[1][:totem_id]
    assert_equal "new@example.com", tracked.first[1][:email]
  end

  test "POST does not track on duplicate email capture" do
    totem = totems(:secondary_totem)
    post api_v1_totem_email_captures_path(totem_slug: totem.slug),
         params: { email: "repeat@example.com" }, as: :json

    tracked = []
    AnalyticsService.stub(:track, ->(name, **props) { tracked << [name, props] }) do
      post api_v1_totem_email_captures_path(totem_slug: totem.slug),
           params: { email: "repeat@example.com" },
           as: :json
    end
    assert_empty tracked
  end
end
