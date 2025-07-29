class ApplicationController < ActionController::Base

  allow_browser versions: :modern

  SECRET_KEY = Rails.application.secret_key_base

  before_action :authenticate_request

  def authenticate_request
    cookie = cookies.signed[:jwt] ? cookies.signed[:jwt] : cookies[:jwt]
    if cookie
      begin
        decoded = JWT.decode(cookie, SECRET_KEY, true, algorithm: 'HS256')[0]
        @current_user = User.find(decoded["user_id"])
      rescue JWT::DecodeError
        @current_user = nil
      end
    else
      @current_user = nil
    end
  end


  def current_user
    @current_user ||= authenticate_request
  end

  def check_for_cookies
    if current_user.present?
      redirect_to root_path
    end
  end

  helper_method :current_user
end
