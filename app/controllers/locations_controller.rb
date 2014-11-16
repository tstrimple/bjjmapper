class LocationsController < ApplicationController
  before_action :set_instructor, only: [:instructors]
  before_action :set_location, only: [:destroy, :show, :update, :instructors]
  before_action :set_map, only: :show
  before_action :ensure_signed_in, only: [:destroy, :create, :update]
  decorates_assigned :location

  helper_method :created?

  def show
    tracker.track('showLocation',
      id: @location.to_param
    )

    respond_to do |format|
      format.json { render json: @location }
      format.html
    end
  end

  def destroy
    tracker.track('deleteLocation',
      id: @location.to_param,
      location: @location.as_json({})
    )

    @location.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render status: :ok, json: @location }
    end
  end

  def create
    location = Location.create(create_params)

    tracker.track('createLocation',
      location: location.as_json({})
    )

    respond_to do |format|
      format.json { render json: location }
      format.html { redirect_to location_path(location, edit: 1, create: 1) }
    end
  end

  def update
    tracker.track('updateLocation',
      id: @location.to_param,
      location: @location.as_json({}),
      updates: create_params
    )

    @location.update!(create_params)

    respond_to do |format|
      format.json { render json: @location }
      format.html { redirect_to location_path(location, edit: 0) }
    end
  end

  def search
    center = params.fetch(:center, nil)
    team = params.fetch(:team, nil)
    distance = params.fetch(:distance, 5.0)

    text_filter = params.fetch(:query, nil)
    filter_ids = Location.search_ids(text_filter).try(:to_set) if text_filter.present?

    head :bad_request and return unless center.is_a?(Array) && center.present?

    locations = Location.near(center, distance).limit(50)
    locations = locations.where(:team_id.in => team) if team.present?
    locations = locations.select do |location|
      filter_ids.include?(location.to_param)
    end if text_filter.present?

    head :no_content and return unless locations.present?

    decorated_locations = LocationDecorator.decorate_collection(locations.to_a)
    decorated_locations.each do |loc|
      loc.distance = Geocoder::Calculations.distance_between(loc.to_coordinates, center)
    end

    tracker.track('searchLocations',
      center: center,
      team: team,
      distance: distance,
      text_filter: text_filter,
      results: decorated_locations.count,
      location: location.as_json({})
    )

    respond_to do |format|
      format.json { render json: decorated_locations }
    end
  end

  def index
    @criteria = params.slice(:city, :country) || {}
    if @criteria.key?(:city) && @criteria.key?(:country)
      @locations = Location.near(@criteria.values.join(','), 30)
    elsif @criteria.key?(:country)
      @locations = Location.where(:country => @criteria[:country])
    else
      @locations = []
    end

    tracker.track('showLocationsIndex',
      city: @criteria[:city],
      country: @criteria[:country],
      count: @locations.count,
    )

    respond_to do |format|
      format.html
      format.json { render json: @locations }
    end
  end

  private

  def created?
    return params.fetch(:create, 0).to_i.eql?(1)
  end

  def set_instructor
    @instructor = User.find(params[:instructor_id]) if params.key?(:instructor_id)
    head :not_found and return false unless @instructor.present?
  end

  def set_map
    @map = {
      :zoom => Map::ZOOM_LOCATION,
      :center => @location.to_coordinates,
      :geolocate => 0,
      :locations => [],
      :filters => 0
    }
  end

  def create_params
    p = params.require(:location).permit(:city, :street, :postal_code, :state, :country, :title, :description, :coordinates, :team_id, :directions, :phone, :email, :website)
    p[:coordinates] = JSON.parse(p[:coordinates]) if p.key?(:coordinates)
    p[:modifier] = current_user if signed_in?
    p
  end

  def set_location
    @location = Location.find(params[:id])
    render status: :not_found and return unless @location.present?
  end
end
