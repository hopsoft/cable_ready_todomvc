require "securerandom"

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action do
    cookies.signed[:user_id] ||= SecureRandom.uuid
  end
end
