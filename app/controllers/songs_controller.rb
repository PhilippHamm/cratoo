class SongsController < ApplicationController
  def suggestion
    @suggestion = Song.all.sample
  end
end
