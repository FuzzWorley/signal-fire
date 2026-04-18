class PushNotificationService
  EXPO_PUSH_URL = "https://exp.host/--/api/v2/push/send"

  Result = Data.define(:ok, :error)

  def self.deliver(push_token:, title:, body:, data: {}, http_client: Net::HTTP)
    return Result.new(ok: false, error: "blank token") if push_token.blank?

    payload = { to: push_token, title: title, body: body, data: data }.to_json

    response = http_client.post(
      URI(EXPO_PUSH_URL),
      payload,
      "Content-Type" => "application/json",
      "Accept"       => "application/json"
    )

    body_json = JSON.parse(response.body)
    expo_status = body_json.dig("data", "status")

    if expo_status == "error"
      details = body_json.dig("data", "details", "error")
      Rails.logger.warn("[PushNotificationService] Expo error for token #{push_token}: #{details}")
      Result.new(ok: false, error: details)
    else
      Result.new(ok: true, error: nil)
    end
  rescue StandardError => e
    Rails.logger.error("[PushNotificationService] #{e.class}: #{e.message}")
    Result.new(ok: false, error: e.message)
  end
end
