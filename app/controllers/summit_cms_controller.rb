class SummitCmsController < ApplicationController
  # Backing store key in the `site_content` table.
  CMS_KEY = "summit_cms".freeze

  # Only saving requires an unlocked session. Reading is public because the
  # summit content is public anyway, and the auth check itself must be reachable.
  before_action :require_unlocked, only: :save

  # GET /summit/cms/data
  # Returns the saved CMS JSON, or null so the client falls back to the
  # bundled defaults in public/summit/cms-data.js.
  def data
    raw    = SiteContent.get(CMS_KEY)
    parsed = raw.present? ? JSON.parse(raw) : nil
    render json: { data: parsed }
  rescue JSON::ParserError
    render json: { data: nil }
  end

  # POST /summit/cms/auth
  # Verifies the passcode on the SERVER (never in client JS) and, on success,
  # marks the session as unlocked so subsequent saves are allowed.
  def auth
    if password_correct?(params[:password].to_s)
      session[:summit_cms_unlocked] = true
      render json: { ok: true }
    else
      render json: { ok: false }, status: :unauthorized
    end
  end

  # POST /summit/cms/save
  # Persists the full CMS JSON payload to the database. Requires an unlocked
  # session (see require_unlocked).
  def save
    body = request.raw_post
    JSON.parse(body) # validate; raises JSON::ParserError on malformed input
    SiteContent.set(CMS_KEY, body)
    render json: { ok: true, message: "Saved" }
  rescue JSON::ParserError
    render json: { ok: false, message: "Invalid JSON" }, status: :unprocessable_entity
  end

  private

  def password_correct?(input)
    expected = cms_password
    return false if expected.blank?

    # Constant-time compare over fixed-length digests to avoid timing/length leaks.
    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(input),
      Digest::SHA256.hexdigest(expected)
    )
  end

  # The passcode lives in an environment variable, never in the codebase.
  # In production, if it isn't set the CMS stays locked (random unguessable
  # value); in development it falls back to a known value for local testing.
  def cms_password
    ENV.fetch("SUMMIT_CMS_PASSWORD") { Rails.env.production? ? nil : "admin2026" }
  end

  def require_unlocked
    head :unauthorized unless session[:summit_cms_unlocked]
  end
end
