module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin

    private

    def authenticate_admin
      return if Rails.env.development?
      authenticate_or_request_with_http_basic("TSOI Admin") do |u, p|
        u == ENV.fetch("ADMIN_USER", "tsoi") &&
        p == ENV.fetch("ADMIN_PASS", "changeme")
      end
    end
  end
end
