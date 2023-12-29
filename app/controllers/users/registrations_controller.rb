class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  skip_before_action :verify_authenticity_token, only: [:create]
  respond_to :json

  before_action :configure_permitted_parameters

  private

  def configure_permitted_parameters
    # rubocop:disable Style/SymbolArray
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation, :phone_number])
    # rubocop:enable Style/SymbolArray
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully', data: resource }
      }, status: :ok
    else
      render json: {
        status: { message: 'User could not be created successfully', errors: resource.errors.full_messages }
      }, status: :unprocessable_entity
    end
  end
end
