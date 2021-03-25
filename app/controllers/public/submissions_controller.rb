# frozen_string_literal: true

class Public::SubmissionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create new_place create_place new_image create_image finished]
  layout 'submission'

  around_action :switch_locale

  SUBMISSION_STATUS_STEP1 = 1
  SUBMISSION_STATUS_STEP2 = 2
  SUBMISSION_STATUS_STEP3 = 3

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options(options = {})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { locale: I18n.locale }
  end

  def new
    return unless layer_from_id.positive?

    @layer = Layer.find(layer_from_id)
    return unless @layer.public_submission

    @submission = Submission.new
    @submission.name = params[:name]
    @submission.locale = params[:locale]
    @submission.email = params[:email]
    @submission.privacy = params[:privacy]
    @submission.rights = params[:rights]

    @map = @layer.map
    @user = User.new
  end

  def create
    @submission = Submission.new(submission_params)
    @submission.status = SUBMISSION_STATUS_STEP1
    @layer = Layer.find(layer_from_id)
    return unless @layer.public_submission

    @map = @layer.map

    respond_to do |format|
      if @submission.save
        session[:submission_id] = @submission.id
        format.html { redirect_to submission_new_place_path(locale: params[:locale], submission_id: @submission.id, layer_id: layer_from_id), notice: 'Submission was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def new_place
    return unless session[:submission_id].positive?

    @submission = Submission.find(session[:submission_id])
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
    return unless session[:submission_id].positive?

    @submission = Submission.find(session[:submission_id])
    @place = Place.new(place_params)
    @place.layer_id = layer_from_id
    @place.title = @submission.name
    @layer = Layer.find(layer_from_id)
    @map = @layer.map

    respond_to do |format|
      if @place.save
        @submission.place = @place
        @submission.status = SUBMISSION_STATUS_STEP2
        @submission.save!
        format.html { redirect_to submission_new_image_path(params[:locale], layer_id: layer_from_id), notice: t('activerecord.messages.models.place.created') }
      else
        format.html { render :new_place }
      end
    end
  end

  def new_image
    return unless session[:submission_id].positive?

    @image = Image.new

    @layer = Layer.find(layer_from_id)
    @map = @layer.map
    @submission = Submission.find(session[:submission_id])
    @place = @submission.place
  end

  def create_image
    return unless session[:submission_id].positive?

    @submission = Submission.find(session[:submission_id])
    @image = Image.new(image_params)
    @layer = Layer.find(layer_from_id)
    @map = @layer.map
    @place = @submission.place
    respond_to do |format|
      if params[:image_upload]
        if @image.save
          @submission.status = SUBMISSION_STATUS_STEP3
          @submission.save!

          format.html { redirect_to submission_finished_path(params[:locale], submission_id: @submission.id, layer_id: layer_from_id), notice: t('activerecord.messages.models.image.created') }
        else
          format.html { render :new_image }
        end
      else
        @submission.status = SUBMISSION_STATUS_STEP3
        @submission.save!

        format.html { redirect_to submission_finished_path(params[:locale], submission_id: @submission.id, layer_id: layer_from_id), notice: t('submission.finished') }
      end
    end
  end

  def finished
    return unless session[:submission_id].positive?

    @submission = Submission.find(session[:submission_id])
    @place = @submission.place
    @image = Image.sorted_by_place(session[:place_id])
    @layer = Layer.find(layer_from_id)
    @map = @layer.map
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
