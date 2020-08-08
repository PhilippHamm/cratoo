require 'pry-byebug'

class UsersController < ApplicationController
  def spotify
    # Authorize Spotify user
    @spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    # Now you can access user's private data, create playlists and much more

    # Call private Method to find matches in Spotify
    @track_ids = find_spotify_tracks
    # Call private method to create playlist in Spotify
    @playlist = spotify_playlist
  end

  private

  def spotify_playlist
    # Create playlist in user's Spotify account
    playlist = @spotify_user.create_playlist!('Cratoo Playlist')

    spotify_tracks = []
    # Add tracks to a playlist in user's Spotify account
    @track_ids.each do |track_id|
      spotify_tracks.push(RSpotify::Track.find(track_id))
    end
    playlist.add_tracks!(spotify_tracks)
    playlist
  end

  def find_spotify_tracks
    jarow = FuzzyStringMatch::JaroWinkler.create(:native)
    # is that really necessary
    # RSpotify.authenticate("f89128215edc44adb16bfe8fb2aba93d", "05678f9267a04d7daaa62f208d2f062c")

    # Find all playlist related to this user
    @likes = Playlist.find_by(name: "Likes", user_id: current_user.id)
    @dislikes = Playlist.find_by(name: "Dislikes", user_id: current_user.id)
    @likes_without_match = Playlist.find_by(name: "Likes without match", user_id: current_user.id)

    # songs of likes Playlist and push them into array
    crate_digs = PlaylistSong.where(playlist_id: @likes.id)
    @playlist_track_ids = []


    # Find for all playlist songs a song in Spotify by iterating over array
    crate_digs.each do |crate_dig|
      song = Song.find(crate_dig.song_id)
      album = Album.find(song.album_id)

      # Bring names of artist, album and song to form which spotify understands
      artist_name_prepared = Artist.find(song.artist_id).name.gsub(/[^a-zA-Z0-9, ]/,"").gsub(/ $/,"")

      # If various artist name string, than build array of two, else array of one
      if artist_name_prepared.include?(",")
        artist_name_array = artist_name_prepared.split(",")
      else
        artist_name_array = [artist_name_prepared]
      end
      album_name_prepared = album.name.gsub(/[^a-zA-Z0-9 ]/,"").gsub(/ $/,"")
      song_title_prepared = song.title.gsub(/[^a-zA-Z0-9]/,"").gsub(/ $/,"")

      # Search for match via tracks path in Spotify
      spotify_tracks = RSpotify::Track.search(song_title_prepared)
      spotify_track = spotify_tracks.select {|track| jarow.getDistance(track.artists.first.name.downcase, artist_name_array.first.downcase) > 0.9 }

      if spotify_track.first.nil?
        # Search for match via albums path in Spotify
        spotify_albums = RSpotify::Album.search(album_name_prepared)
        # Iterating over artist array
        artist_name_array.each do |artist_name|
          spotify_album = spotify_albums.select {|album| jarow.getDistance(album.artists.first.name.downcase, artist_name.downcase) > 0.9 }
            unless spotify_album.first.nil?
              spotify_track = spotify_album.first.tracks.select{|track| jarow.getDistance(track.name.downcase, song_title_prepared.downcase) > 0.9 }
            end
          break unless spotify_track.first.nil?
        end
        if spotify_track.first.nil?
          # Search for match via artists path in Spotify
          artist_name_array.each do |artist_name|
            spotify_artists = RSpotify::Artist.search(artist_name)
            spotify_artists.each do |artist|
              spotify_album = artist.albums.select{|album| jarow.getDistance(album.name.downcase, album_name_prepared.downcase) > 0.9 }
              unless spotify_album.first.nil?
                spotify_track = spotify_album.first.tracks.select{|track| jarow.getDistance(track.name.downcase, song_title_prepared.downcase) > 0.9 }
                break
              end
              # Search for match via artists, album, every track path in Spotify (very slow)
              if spotify_track.first.nil?
                artist.albums.each do |album|
                  album.tracks.each do |track|
                    if jarow.getDistance(track.name.downcase, song_title_prepared.downcase) > 0.9
                      spotify_track = [track]
                    end
                  end
                end
              end
            end
            break unless spotify_track.first.nil?
          end
        end
      end

      # Move tracks which where not matched into likes without match
      # Move tracks which where matched into dislikes
      # so that they are not suggested again

      if spotify_track.first.nil?
        crate_dig.playlist_id = @likes_without_match.id
        crate_dig.save
      else
        crate_dig.playlist_id = @dislikes.id
        crate_dig.save
        # Push id of matched song to array
        @playlist_track_ids.push(spotify_track.first.id)
      end

    end

    @playlist_track_ids
  end
end
