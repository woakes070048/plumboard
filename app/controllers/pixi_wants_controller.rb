class PixiWantsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data
  respond_to :html, :js, :mobile, :json

  def create
    @want = @user.pixi_wants.build(pixi_id: params[:id], status: 'active', quantity: 1)
    respond_with(@want) do |format|
      if @want.save
        reload_data params[:id]
        format.json { render json: { pixi_want: @want } }
      else
        format.json { render json: { errors: @want.errors.full_messages }, status: 422 }
      end
    end
  end

  protected

  def load_data
    @url = params[:url]
  end

  def reload_data pid
    @listing = Listing.find_by_pixi_id pid
  end
end