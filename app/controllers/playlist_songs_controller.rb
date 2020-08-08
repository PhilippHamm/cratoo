require 'rspotify'
require 'fuzzystringmatch'

class PlaylistSongsController < ApplicationController
  def create
    # Create Dislike and Likes Playlist of User
    if Playlist.where(user_id: current_user.id).count < 1
      @likes = Playlist.new(name: "Likes", user_id: current_user.id)
      @likes.save
      @dislikes = Playlist.new(name: "Dislikes", user_id: current_user.id)
      @dislikes.save
      @likes_without_match = Playlist.new(name: "Likes without match", user_id: current_user.id)
      @likes_without_match.save
    end
    # Find Dislike and Likes Playlist of User
    @likes = Playlist.find_by(name: "Likes", user_id: current_user.id)
    @dislikes = Playlist.find_by(name: "Dislikes", user_id: current_user.id)
    @likes_without_match = Playlist.find_by(name: "Likes without match", user_id: current_user.id)
    # Add Songs to Dislike and Likes Playlist of User
    if params[:status] == "like"
      user_choice = PlaylistSong.new(playlist_id: @likes.id, song_id: params[:song_id].to_i)
    else
      user_choice = PlaylistSong.new(playlist_id: @dislikes.id, song_id: params[:song_id].to_i)
    end
    user_choice.save
    # Ask user if user wants to check Crate digs
    if PlaylistSong.where(playlist_id: @likes.id).count % 1 == 0
      playlist = true
    else
      playlist = false
    end
    redirect_to suggestion_songs_path(playlist: playlist)
  end

  def empty
    # playlist_songs = PlaylistSong.where(playlist_id: @likes.id)
    # playlist_songs.each do |playlist_song|
    #   #!!!!!!!!!!!
    #   # Move tracks which where not matched into likes without match
    #   playlist_song.playlist_id = @likes_without_match.id
    #   # Move tracks which where matched into dislikes
    #   # so that they are not suggested again
    #   playlist_song.playlist_id = @dislikes.id
    # end
    # redirect_to suggestion_songs_path
  end

  def destroy
  end
end
