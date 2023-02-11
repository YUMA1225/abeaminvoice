class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    if user_signed_in?
    @user = User.find(current_user.id)
    end
  end

  def edit

    @user = User.find(params[:id])
    if @user.id != current_user.id
      redirect_to customers_path, alert: '不正なアクセスです' 
    end
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    redirect_to root_path
  end

  def show

  end

  private
  def user_params
    params.require(:user).permit(:username, :company, :email, :account)
  end

end
