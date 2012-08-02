class MainController < ApplicationController

  def index
    if current_user
      @artists = current_user.artists
      @tracks = current_user.tracks
      @albums = current_user.albums
    end
  end

  def about
    render :layout => false
  end

  def add
    if ['album', 'track'].include? params[:type]
      query = params[:query].split(' :: ')[0]
    else
      query = params[:query]
    end

    type_class = params[:type].camelize.constantize
    created = type_class.create_from_spotify(query)

    hash = {:name => created[:name], :spotify_uri => created[:spotify_uri], :user_id => current_user.id}
    hash[:artist_name] = created[:artist] if !created[:artist].empty?
    new_data = type_class.new(hash)

    if new_data.save
      render :json => { :results => { :name => created[:name], :artist => created[:artist], :href => created[:spotify_uri] }, :id => new_data.id }
    end
  end

  def listen
    data = params[:type].camelize.constantize.find(params[:id])

    if data.update_attribute(:listened_to, true)
      render :json => { :listened_to => true }
    end
  end

  def remove
    data = params[:type].camelize.constantize.find(params[:id])

    data.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

end
