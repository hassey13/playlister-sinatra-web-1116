require 'rack-flash'

class ApplicationController < Sinatra::Base

  register Sinatra::ActiveRecordExtension
  set :session_secret, "my_application_secret"
  set :views, Proc.new { File.join(root, "../views/") }

  enable :sessions
  use Rack::Flash


  get '/' do
    erb :index
  end

  get '/songs' do
    @songs = Song.all
    erb :'songs/index'
  end

  get '/songs/new' do
    @artists = Artist.all
    @genres = Genre.all
    erb :'songs/new'
  end

  post '/songs' do
    @song = Song.create(params[:song])

    @artist = Artist.find_or_create_by(name: params[:artist][:name])
    @artist = Artist.find(id: params[:artist][:artist_id]) unless params[:artist][:artist_id].nil?
    @song.artist_id = @artist.id if !@artist.nil?

    @song.save

    @genre = Genre.find_or_create_by(name: params[:genre][:name]) unless params[:genre][:name] == ""

    params[:genre][:genre_ids] ||= []
    params[:genre][:genre_ids] << @genre.id unless @genre.nil?
    params[:genre][:genre_ids].compact!
    @song.update(genre_ids: params[:genre][:genre_ids])

    flash[:message] = "Successfully created song."

    redirect "/songs/#{@song.slug}"
  end

  get '/songs/:slug/edit' do
    @song = Song.find_by_slug(params[:slug])
    @artists = Artist.all
    @genres = Genre.all
    erb :'songs/edit'
  end

  patch '/songs/:slug' do
    @song = Song.find_by_slug(params[:slug])
    @song.update(params[:song])

    # artist name
      # input artist id != current artist id -- overwrite

    # checkboxes
      # checkbox id != current artist id -- overwrite * as long as there is something there

      #   There are checked boxes         and  artist input not = current artist
    if params[:artist][:name] != "" && Artist.find_or_create_by(name: params[:artist][:name]).id != @song.artist.id
      @artist = Artist.find_or_create_by(name: params[:artist][:name])
      @song.artist_id = @artist.id
      @song.save

      # @artist = Artist.find(params[:artist][:artist_ids]).first

        #  there is a name in input     and  there checked boxes
    elsif !params[:artist][:artist_ids].empty?
      @song.artist_id = params[:artist][:artist_ids].first.to_i
      @song.save

    end

    @genre = Genre.find_or_create_by(name: params[:genre][:name]) unless params[:genre][:name] == ""

    params[:genre][:genre_ids] ||= []
    params[:genre][:genre_ids] << @genre.id unless @genre.nil?
    params[:genre][:genre_ids].compact!
    @song.update(genre_ids: params[:genre][:genre_ids])

    flash[:message] = "Successfully updated song."
    erb :'songs/show'
  end

  get '/songs/:slug' do
    @song = Song.find_by_slug(params[:slug])
    erb :'songs/show'
  end

  get '/genres' do
    @genres = Genre.all
    erb :'genres/index'
  end

  get '/genres/:slug' do
    @genre = Genre.find_by_slug(params[:slug])
    @artists = @genre.artists
    @songs = @genre.songs
    erb :'genres/show'
  end

  get '/artists' do
    @artists = Artist.all
    erb :'artists/index'
  end

  get '/artists/:slug' do
    @artist = Artist.find_by_slug(params[:slug])
    @songs = @artist.songs
    @genres = @artist.genres
    erb :'artists/show'
  end


end
