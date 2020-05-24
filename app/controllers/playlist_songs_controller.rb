class PlaylistSongsController < ApplicationController
  def create
    if Playlist.where(user_id: current_user.id).count == 1
      likes = Playlist.new(name: "Likes", user_id: current_user.id)
      likes.save
      dislikes = Playlist.new(name: "Dislikes", user_id: current_user.id)
      dislikes.save
    end
    likes = Playlist.find_by(name: "Likes", user_id: current_user.id)
    dislikes = Playlist.find_by(name: "Dislikes", user_id: current_user.id)
    if params[:status] == "like"
      user_choice = PlaylistSong.new(playlist_id: likes.id, song_id: params[:song_id].to_i)
    else
      user_choice = PlaylistSong.new(playlist_id: dislikes.id, song_id: params[:song_id].to_i)
    end
    user_choice.save

    if PlaylistSong.where(playlist_id: likes.id).count % 1 == 0
      playlist = true
    else
      playlist = false
    end
    redirect_to suggestion_songs_path(playlist: playlist)
  end
end
