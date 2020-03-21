class AssetsController < ApplicationController
  before_action :set_asset, only: [:show, :update, :destroy]

  # GET /assets
  def index
    @assets = Asset.all

    render json: @assets
  end

  # GET /assets/1
  def show
    render json: @asset
  end

  # POST /assets
  def create
    @asset = Asset.new(asset_params)

    if @asset.save
      render json: @asset, status: :created, location: @asset
    else
      render json: @asset.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /assets/1
  def update
    if @asset.update(asset_params)
      render json: @asset
    else
      render json: @asset.errors, status: :unprocessable_entity
    end
  end

  # DELETE /assets/1
  def destroy
    @asset.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset
      @asset = Asset.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def asset_params
      params.require(:asset).permit(:name, :description, :bucket_url)
    end
end
