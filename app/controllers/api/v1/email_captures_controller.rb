class Api::V1::EmailCapturesController < ActionController::API
  def create
    totem = Totem.find_by(slug: params[:totem_slug])
    return render json: { error: "Not found" }, status: :not_found unless totem

    email = params[:email]&.downcase&.strip
    return render json: { error: "email is required" }, status: :unprocessable_entity if email.blank?

    capture = totem.empty_totem_email_captures.find_or_initialize_by(email: email)
    if capture.persisted?
      return render json: { captured: true }
    end

    capture.captured_at = Time.current
    if capture.save
      AnalyticsService.track("empty_totem_email_captured",
        totem_id: totem.id, email: email)
      render json: { captured: true }, status: :created
    else
      render json: { error: capture.errors.full_messages.first }, status: :unprocessable_entity
    end
  end
end
