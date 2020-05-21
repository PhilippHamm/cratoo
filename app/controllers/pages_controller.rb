class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home ]

  def home
  end

  def suggested_songs
    @song = Song.all.order("score DESC").limit(1).offset(1)
    # @song = @suggested_songs.first
  end
end
