class ListingsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_listing, only: %i[show]

  def host
    @listings = current_user.listings
  end

  def index
    @listings = Listing.all

    @listings = filter_by_location(@listings) if params[:location].present?
    @listings = filter_by_guests(@listings) if params[:guests].present?
  end

  def show
    @marker = {
      lat: @listing.latitude,
      lng: @listing.longitude
    }

    @unavailable_dates = @listing.booked_dates.to_json
  end

  def new
    @listing = Listing.new
  end

  def create
    @listing = Listing.new(listing_params)
    @listing.host = current_user
    if @listing.save
      redirect_to :root
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @listing = current_user.listings.find(params[:id])
    @listing.destroy
    redirect_to host_listings_path, status: :see_other
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(:name, :details, :location, :max_guests, :price_per_night, photos: [])
  end

  def filter_by_location(listings)
    listings.where("location ILIKE ?", "%#{params[:location]}%")
  end

  def filter_by_guests(listings)
    listings.where("max_guests >= #{params[:guests]}")
  end
end
