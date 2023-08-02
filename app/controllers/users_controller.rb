class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show update]
 
  def index
    @users = User.all
    render json: @users
  end

  def show
    render json: @user
  end
  # def show
  #   @user = User.find(params[:id])
  #   respond_to do |format|
  #     format.json { render json: { name: @user.name, email: @user.email } }
  #     format.html { render 'show' }
  #   end
  # end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

 
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

 
 
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
