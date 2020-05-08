class FavoritesController < ApplicationController
  def new
    if @users_favorite = Favorite.find(user_id = current_user.id)
      redirect_to favorite_path(@users_favorite)
    else
      create
    end
  end

  def create
    @users_favorite = Favorite.new(user_id: current_user.id)
    if @users_favorite.save
      redirect_to favorite_path(@users_favorite)
    else
      redirect_to root_path
    end
  end

  def show
    @user_favorite = Favorite.find(params[:id])
  end

end
