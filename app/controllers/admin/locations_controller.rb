class Admin::LocationsController < Admin::AdminController
  def show
    id_param = params.fetch(:id, '')
    @location = Location.find(id_param)
  end
  
  def fetch
    id_param = params.fetch(:id, '')
    @location = Location.find(id_param)
    @location.search_metadata!
    head :no_content
  end

  def index
    @locations = Location.limit(100).sort({created_at:-1})
  end

  def pending
    @locations = Location.limit(100).pending.sort({status_updated_at: 1})
  end

  def rejected
    @locations = Location.limit(100).rejected.sort({created_at:-1})
  end

  def moderate
    redirect_to location_path(Location.pending.sort({status_updated_at: 1}).first, moderate: 1)
  end
end
