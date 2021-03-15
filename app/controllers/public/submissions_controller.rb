# frozen_string_literal: true

class Public::SubmissionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create new_place create_place new_image create_image]
  layout 'submission'
  def new
    return unless layer_from_id.positive?

    @submission = Submission.new
    @submission.name = params[:name]
    @submission.locale = params[:locale]
    @submission.email = params[:email]
    @submission.privacy = params[:privacy]
    @submission.rights = params[:rights]

    @layer = Layer.find(layer_from_id)
    @map = @layer.map
    @user = User.new
  end

  # POST /submissions
  # POST /submissions.json
  def create
    @submission = Submission.new(submission_params)
    @layer = Layer.find(layer_from_id)
    @map = @layer.map

    respond_to do |format|
      if @submission.save
        format.html { redirect_to submission_new_place_path(locale: 'de', submission_id: @submission.id, layer_id: layer_from_id), notice: 'Submission was successfully created.' }
        format.json { render :show, status: :created, location: @place }
      else
        format.html { render :new }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  def new_place
    print params.inspect

    @submission = Submission.find(submission_from_id)
    @layer = Layer.find(layer_from_id)
    @map = @layer.map

    @place = Place.new
    @place.location = params[:location]
    @place.address = params[:address]
    @place.zip = params[:zip]
    @place.city = params[:city]
    @place.lat = params[:lat]
    @place.lon = params[:lon]
    @place.layer_id = layer_from_id
  end

  def create_place
    @submission = Submission.find(submission_from_id)
    @place = Place.new(place_params)
    @place.layer_id = layer_from_id
    @place.title = @submission.name
    @submission.place = @place
    @layer = Layer.find(layer_from_id)
    @map = @layer.map

    respond_to do |format|
      if @place.save
        # @submission.save!
        format.html { redirect_to submission_new_image_path(locale: 'de', place_id: @place.id, submission_id: @submission.id, layer_id: layer_from_id), notice: 'Place was successfully created.' }
        format.json { render :show, status: :created, location: @place }
      else
        format.html { render :new_place }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  def new_image
    @image = Image.new

    @layer = Layer.find(layer_from_id)
    @map = @layer.map
    @place = Place.find(place_from_id)
    @submission = Submission.find(submission_from_id)
  end

  def create_image
    @submission = Submission.find(submission_from_id)
    @image = Image.new(image_params)
    @layer = Layer.find(layer_from_id)
    @map = @layer.map
    @place = Place.find(place_from_id)
    respond_to do |format|
      if @image.save
        format.html { redirect_to submission_finished_path(locale: 'de', place_id: @place.id, submission_id: @submission.id, layer_id: layer_from_id), notice: 'Your contribution has been saved' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new_image }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  def finished
    @submission = Submission.find(submission_from_id)

    print @submission.inspect
    @image = Image.sorted_by_place(place_from_id)
    @layer = Layer.find(layer_from_id)
    @map = @layer.map
    @place = Place.find(place_from_id)
  end


  def layer_from_id
    params[:layer_id].to_i
  end

  def place_from_id
    return params[:place_id].to_i unless params[:place_id].nil?
    return params[:image_place_id].to_i unless params[:image_place_id].nil?
    0
  end

  def submission_from_id
    params[:submission_id].to_i
  end

  def place_params
    params.require(:place).permit(:title, :teaser, :text, :lat, :lon, :location, :address, :zip, :city, :country, :published, :featured, :imagelink, :layer_id, :icon_id, :audio, tag_list: [], images: [], videos: [])
  end

  def submission_params
    params.require(:submission).permit(:rights, :privacy, :email, :locale, :name)
  end

  def image_params
    params.require(:image).permit(:title, :licence, :source, :creator, :place_id, :alt, :caption, :sorting, :preview, :file)
  end
end
