class SongsController < ApplicationController
  def suggestion
    @suggestion = Song.all.sample
    likes = Playlist.find_by(name: "Likes", user_id: current_user.id)
    dislikes = Playlist.find_by(name: "Dislikes", user_id: current_user.id)
    until PlaylistSong.find_by(playlist_id: likes.id, song_id: @suggestion.id).nil? && PlaylistSong.find_by(playlist_id: dislikes.id, song_id: @suggestion.id).nil?
      @suggestion = Song.all.sample
    end
    @check_playlist = params[:playlist]
  end
end
