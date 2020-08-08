require 'pry-byebug'

class SongsController < ApplicationController
  def suggestion
    # If user hasn't like or disliked any track take a sample of all tracks
    # if user liked or disliked a track only suggest tracks not heard yet

    if Playlist.where(user_id: current_user.id).first.nil?
      @suggestion = Song.all.sample
    else
      # Find all user Playlists
      likes = Playlist.find_by(name: "Likes", user_id: current_user.id)
      dislikes = Playlist.find_by(name: "Dislikes", user_id: current_user.id)
      likes_without_match = Playlist.find_by(name: "Likes without match", user_id: current_user.id)
      # Sum all already suggested tracks
      sum = PlaylistSong.where(playlist_id: likes.id).length + PlaylistSong.where(playlist_id: dislikes.id).length + PlaylistSong.where(playlist_id: likes_without_match.id).length
      # Assign a song that is not in one of the playlist if there are
      # Assign a song only if genre is equal to selected one
      if Song.all.length > sum
        @suggestion = Song.all.sample
        until PlaylistSong.find_by(playlist_id: likes.id, song_id: @suggestion.id).nil? && PlaylistSong.find_by(playlist_id: dislikes.id, song_id: @suggestion.id).nil? && PlaylistSong.find_by(playlist_id: likes_without_match.id, song_id: @suggestion.id).nil?
          @suggestion = Song.all.sample
        end
      end
    end
    @check_playlist = params[:playlist]
  end
end
