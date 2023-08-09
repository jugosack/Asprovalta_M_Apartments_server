# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json
  # skip_before_action :verify_authenticity_token, only: [:destroy] # Skip CSRF protection for sign-out
  skip_before_action :verify_authenticity_token, only: [:destroy, :create] # Skip CSRF protection for sign-in and sign-out

  # DELETE /resource/sign_out
  # def destroy
  #   sign_out(resource_name) # Devise method for sign-out
  #   # head :no_content # Return a 204 No Content response
  #   render json: { message: 'Successfully logged out.' }, status: :ok
  # end

  def respond_with(resource, _opts = {})
    render json: {
      status: { code: 200, message: "User signed in successfully", data: current_user }
    }, status: :ok
  end

  def respond_to_on_destroy
    jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1], Rails.application.credentials.fetch(:secret_key_base)).first
    current_user = User.find(jwt_payload['sub'])
    if current_user
      render json: {
        status: 200,
        message: "Signed out successfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "User has no active session"
      }, status: :unauthorized
    end
  end
end