class InstructorsController < ApplicationController
  before_filter :set_location
  before_filter :set_instructor, only: [:destroy]

  def create
    @instructor = if params.has_key? :user
      User.create!(create_params)
    else
      User.find(params[:id])
    end

    @location.instructors << @instructor
    respond_to do |format|
      format.html { redirect_to location_path(@location, edit: 1) }
      format.json { render :json => {}, :status => :ok }
    end
  end

  def destroy
    @location.instructors.delete(@instructor)
    respond_to do |format|
      format.html { redirect_to location_path(@location, edit: 1) }
      format.json { render :json => {}, :status => :ok }
    end
  end

  private

  def create_params
    params.require(:user).permit(:name, :email, :belt_rank, :stripe_rank)
  end

  def set_location
    @location = Location.find(params[:location_id])
    head :not_found and return false unless @location.present?
  end

  def set_instructor
    @instructor = @location.instructors.find(params[:id])
    head :not_found and return false  unless @instructor.present?
  end
end
