require 'csv'

class ArtistsController < ApplicationController
  def create
    genre = params[:genre]
    csv_options = { col_sep: ',', headers: :first_row }
    filepath    = Rails.root.join('lib', 'data', "#{genre}_#{Time.now.strftime('%Y-%m-%d-%H-%M')}_#{quantity}.csv")
  end

end
