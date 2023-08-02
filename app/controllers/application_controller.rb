class ApplicationController < ActionController::Base
  
#  protect_from_forgery prepend: true
protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_action :configure_permitted_parameters, if: :devise_controller?

  

  protected

  # def after_sign_in_path_for(_resource)
  #   user_reservations_path(current_user)
  # end


  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name])
  end

end
