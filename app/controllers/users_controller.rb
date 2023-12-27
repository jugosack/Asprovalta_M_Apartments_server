class UsersController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:update]
  before_action :set_user, only: %i[show update]

  def index
    @users = User.all
    render json: @users
  end

  def show
    render json: @user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update
    if params[:user][:avatar]
      # Create a new ActiveStorage::Blob object from the uploaded file
      avatar = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(Base64.decode64(params[:user][:avatar][:content])),
        filename: params[:user][:avatar][:filename],
        content_type: params[:user][:avatar][:content_type]
      )

      # Attach the avatar image to the user record
      if @user.avatar.attach(avatar)
        render json: @user.as_json(methods: [:avatar])
      else
        render json: { errors: @user.avatar.errors.full_messages }, status: :unprocessable_entity
      end
    elsif @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :phone_number)
  end
end
