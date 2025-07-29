class AuthenticationHelper

  def self.generate_cookie(user)
    token = JWT.encode({user_id: user.id, role: user.role, exp: 24.hours.from_now.to_i}, Rails.application.secret_key_base, 'HS256')
    {Cookie: "jwt=#{token}"}
  end

end