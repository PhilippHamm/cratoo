class PlaylistsController < ApplicationController
  def show
    @playlist = Playlist.find(params[:id].to_i)
    @playlist_songs = PlaylistSong.where(playlist_id: @playlist.id)
  end
end
