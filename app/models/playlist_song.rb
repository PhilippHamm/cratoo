class PlaylistSong < ApplicationRecord
  belongs_to :song
  belonga_to :playlist
end
