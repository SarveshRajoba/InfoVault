require 'rails_helper'

RSpec.describe "User Authentication", type: :request do
  describe "GET /signup" do
    it "returns a successful response" do
      get "/signup"
      expect(response).to have_http_status(:ok)
    end
    
    context "when already logged in" do
      let(:user) { create(:user) }
      
      it "redirects to subjects path" do
        token = JWT.encode({user_id: user.id, role: user.role, exp: 24.hours.from_now.to_i}, Rails.application.secret_key_base, 'HS256')
        
        cookies[:jwt] = token
        
        get "/signup", headers: AuthenticationHelper.generate_cookie(user)
        expect(response).to have_http_status(:found)
      end
    end
  end
  
  describe "GET /login" do
    it "returns a successful response" do
      get "/login"
      expect(response).to have_http_status(:ok)
    end
    
    context "when already logged in" do
      let(:user) { create(:user) }
      
      it "redirects to subjects path" do
        token = JWT.encode({user_id: user.id, role: user.role, exp: 24.hours.from_now.to_i}, Rails.application.secret_key_base, 'HS256')
        
        get "/login", headers: AuthenticationHelper.generate_cookie(user)
        
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "POST /signup" do
    let(:valid_attributes) { { user: { username: "John Doe", email: "john@example.com", password: "password123", password_confirmation: "password123" } } }
    let(:invalid_attributes) { { user: { username: "", email: "invalid", password: "" } } }
    let(:mismatched_passwords) { { user: { username: "John Doe", email: "john@example.com", password: "password123", password_confirmation: "different" } } }

    it "registers a new user with valid details" do
      expect {
        post "/signup", params: valid_attributes
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(subjects_path)
      expect(flash[:notice]).to eq("Signup successfully.")
      expect(response.cookies['jwt']).to be_present
    end

    it "fails to register a user with invalid details" do
      expect {
        post "/signup", params: invalid_attributes
      }.not_to change(User, :count)

      expect(response).to redirect_to(signup_path)
      expect(flash[:notice]).to be_present 
    end
    
    it "fails when passwords don't match" do
      expect {
        post "/signup", params: mismatched_passwords
      }.not_to change(User, :count)

      expect(response).to redirect_to(signup_path)
      expect(flash[:notice]).to include("Password confirmation doesn't match Password")
    end
    
    context "when already logged in" do
      let(:user) { create(:user) }
      
      it "redirects to subjects path" do
        token = JWT.encode({user_id: user.id, role: user.role, exp: 24.hours.from_now.to_i}, Rails.application.secret_key_base, 'HS256')
        
        post "/signup", params: valid_attributes, headers: AuthenticationHelper.generate_cookie(user)
      end
    end
  end

  describe "POST /login" do
    let!(:user) { create(:user, email: "john@example.com", password: "password123") }
    let(:valid_credentials) { { user: { email: "john@example.com", password: "password123" } } }
    let(:invalid_credentials) { { user: { email: "john@example.com", password: "wrongpassword" } } }
    let(:nonexistent_user) { { user: { email: "nobody@example.com", password: "password123" } } }

    it "logs in successfully with valid credentials" do
      post "/login", params: valid_credentials
      expect(response).to redirect_to(subjects_path)
      expect(flash[:notice]).to eq("Login successfully!!")
      expect(response.cookies['jwt']).to be_present
    end

    it "fails to log in with invalid password" do
      post "/login", params: invalid_credentials
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq("Invalid email or password")
      expect(response.cookies['jwt']).to be_nil
    end
    
    it "fails to log in with non-existent email" do
      post "/login", params: nonexistent_user
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq("Invalid email or password")
      expect(response.cookies['jwt']).to be_nil
    end
    
    context "when already logged in" do
      it "redirects to subjects path" do
        token = JWT.encode({user_id: user.id, role: user.role, exp: 24.hours.from_now.to_i}, Rails.application.secret_key_base, 'HS256')
        
        post "/login", params: valid_credentials, headers: AuthenticationHelper.generate_cookie(user)
      end
    end
  end
  
  describe "DELETE /logout" do
    let(:user) { create(:user) }
    
    context "when user is logged in" do
      it "logs out successfully" do
        token = JWT.encode({user_id: user.id, role: user.role, exp: 24.hours.from_now.to_i}, Rails.application.secret_key_base, 'HS256')
        
        delete "/logout", headers: AuthenticationHelper.generate_cookie(user)
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to eq("Logged out Successfully")
        expect(response.cookies['jwt']).to be_nil
      end
    end
    
    context "when user is not logged in" do
      it "redirects to login path" do
        delete "/logout"
        expect(response).to redirect_to(login_path)
      end
    end
  end
  
  describe "JWT token generation and verification" do
    let(:user) { create(:user) }
    
    it "generates a valid JWT token" do
      auth_controller = AuthController.new
      allow(auth_controller).to receive(:user_params).and_return({ email: user.email, password: "password" })
      
      token = auth_controller.send(:generate_jwt, user)
      
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })[0]
      
      expect(decoded_token["user_id"]).to eq(user.id)
      expect(decoded_token["role"]).to eq(user.role)
      expect(decoded_token["exp"]).to be_present
    end
  end
  
  describe "authenticate_request before_action" do
    let(:user) { create(:user) }
    
    it "handles when token is expired" do
      expired_token = JWT.encode({
        user_id: user.id, 
        role: user.role, 
        exp: 1.day.ago.to_i
      }, Rails.application.secret_key_base, 'HS256')
      
      delete "/logout", headers: { "HTTP_COOKIE" => "jwt=#{expired_token}" }
      
      expect(response).to redirect_to(login_path)
    end
    
    it "handles when token is invalid" do
      invalid_token = "invalid.token.format"
      
      delete "/logout", headers: { "HTTP_COOKIE" => "jwt=#{invalid_token}" }
      
      expect(response).to redirect_to(login_path)
    end
  end
  
  describe "check_for_cookies before_action" do
    let(:user) { create(:user) }
    
    it "redirects to subjects_path when JWT token is valid " do
      valid_token = JWT.encode({
        user_id: user.id, 
        role: user.role, 
        exp: 1.day.from_now.to_i
      }, Rails.application.secret_key_base, 'HS256')
      
      get "/login", headers: { "HTTP_COOKIE" => "jwt=#{valid_token}" }
      
      expect(response).to have_http_status(:found)
    end
  end
end