class AuthController < ApplicationController
  
  layout "auth"

    before_action :authenticate_request, only: [:logout ]
    before_action :check_for_cookies, except: [:logout]
    skip_before_action :verify_authenticity_token, only: [:create, :login, :logout]

    SECRET_KEY = Rails.application.secret_key_base


    def new_signup
      @user = User.new
      render :signup
    end 

    def new_login
      @user = User.new
      render :login
    end

    def create
      @user = User.new(user_params)
      if @user.save
        token = generate_jwt(@user)
        cookies.signed[:jwt] = {
          value: token,
          httpOnly: true,
          expires: 24.hours.from_now
      }
        redirect_to subjects_path, notice: "Signup successfully."
      else
        error_message = @user.errors.full_messages.join('<br>')
        redirect_to signup_path, notice: error_message
      end
    end

    def login
      @user = User.new
      user = User.find_by(email: user_params[:email])
      if user && user.authenticate(user_params[:password])
        token = generate_jwt(user)
        cookies.signed[:jwt] = {
          value: token,
          httpOnly: true,
          expires: 24.hours.from_now
        }
        redirect_to subjects_path, notice: "Login successfully!!"
      else
        redirect_to :login, notice: "Invalid email or password"
      end
    end

    def logout
      cookies.delete(:jwt)
      flash[:notice] = "Logged out Successfully"
      redirect_to login_path
    end

    private

    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

    def generate_jwt(user)
      JWT.encode({user_id: user.id, role: user.role, exp: 24.hours.from_now.to_i}, SECRET_KEY, 'HS256')
    end
end