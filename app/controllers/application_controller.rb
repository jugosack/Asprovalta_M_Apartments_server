# class ApplicationController < ActionController::Base
  
#  protect_from_forgery prepend: true

#   before_action :configure_permitted_parameters, if: :devise_controller?

  

#   protected

#   # def after_sign_in_path_for(_resource)
#   #   user_reservations_path(current_user)
#   # end


#   def configure_permitted_parameters
#     devise_parameter_sanitizer.permit(:sign_up, keys: %i[name])
#   end

# end
class ApplicationController < ActionController::API
  before_action :authorized

  def encode_token(payload)
    JWT.encode(payload, 'yourSecret')
  end

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      # header: { 'Authorization': 'Bearer <token>' }
      begin
        JWT.decode(token, 'yourSecret', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def logged_in_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!logged_in_user
  end

  def authorized
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end
end