# require 'active_storage/blob_invalid'

# class UsersController < ApplicationController

#   # skip_before_action :verify_authenticity_token
#   before_action :authenticate_user!
#   skip_before_action :verify_authenticity_token, only: [:update]
#   before_action :set_user, only: %i[show update]

#   def index
#     @users = User.all
#     render json: @users
#   end

#   def show
#     render json: @user
#   end

#   def create
#     @user = User.new(user_params)
#     if @user.save
#       render json: @user, status: :created
#     else
#       render json: @user.errors, status: :unprocessable_entity
#     end
#   end

#   # def update
#   #   if @user.update(user_params)
#   #     render json: @user
#   #   else
#   #     render json: @user.errors, status: :unprocessable_entity
#   #   end
#   # end
#   # def update
#   #   if @user.update(user_params_with_avatar)
#   #     render json: @user
#   #   else
#   #     render json: @user.errors, status: :unprocessable_entity
#   #   end
#   # end

#   # def update
#   #   @user = User.find(params[:id])

#   #   if params[:user][:avatar]
#   #     # Extract the binary data from the base64 content
#   #     base64_content = params[:user][:avatar][:content]
#   #     image_data = Base64.decode64(base64_content)

#   #     # Create a new ActiveStorage::Blob object for the avatar image
#   #     avatar = ActiveStorage::Blob.create_and_upload!(
#   #       io: StringIO.new(image_data),
#   #       filename: params[:user][:avatar][:filename],
#   #       content_type: 'image/jpeg' # Update content type as needed
#   #     )

#   #     # Attach the avatar image to the user record
#   #     if @user.avatar.attach(avatar)
#   #       logger.info("Avatar attached successfully!")
#   #     else
#   #       logger.error("Avatar attachment failed: #{avatar.errors.full_messages.join(', ')}")
#   #     end
#   #   end

#   #   if @user.update(user_params)
#   #     render json: @user
#   #   else
#   #     render json: @user.errors, status: :unprocessable_entity
#   #   end
#   # end

#   def update
#     @user = User.find(params[:id])

#     if params[:user][:avatar]
#       # Create a new ActiveStorage::UploadedFile object from the base64 content
#       avatar_file = ActiveStorage::UploadedFile.new(
#         filename: params[:user][:avatar][:filename],
#         content_type: params[:user][:avatar][:content_type],
#         tempfile: StringIO.new(Base64.decode64(params[:user][:avatar][:content]))
#       )

#       # Create a new ActiveStorage::Blob object from the uploaded file
#       avatar = ActiveStorage::Blob.create_from_uploaded_file!(avatar_file, io: StringIO.new(Base64.decode64(params[:user][:avatar][:content]))
#       )

#       # Check to see if the avatar image is valid
#       if avatar.valid?
#         # Attach the avatar image to the user record
#         @user.avatar.attach(avatar)
#       else
#         # Render a JSON response with the image validation errors
#         render json: { errors: avatar.errors.full_messages }, status: :unprocessable_entity
#       end
#     end

#     # Update the user record
#     if @user.update(user_params)
#       render json: @user
#     else
#       render json: @user.errors, status: :unprocessable_entity
#     end

#   rescue ActiveStorage::BlobInvalid => e
#     render json: { errors: [e.message] }, status: :unprocessable_entity
#   end

#   private

#   def set_user
#     @user = User.find(params[:id])
#   end

#   def user_params
#     # params.require(:user).permit(:name, :email)
#     params.require(:user).permit(:name, :email, :password, :password_confirmation,  avatar: [:content, :filename])

#   end

#   def user_params_with_avatar
#     # Allow updating name, email, password, password_confirmation, and avatar
#     params.require(:user).permit(:name, :email, :password, :password_confirmation, avatar: [:content, :filename])

# end

# end

class UsersController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:update]
  before_action :set_user, only: [:show, :update]

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
    else
      if @user.update(user_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end
  rescue => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
