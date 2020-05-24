class PlaylistsController < ApplicationController
  def show
    @playlist = Playlist.find_by(user_id: current_user.id, name:"Likes")
    @playlist_songs = PlaylistSong.where(playlist_id: @playlist.id)
  end
end
