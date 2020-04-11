# frozen_string_literal: true

class AssetsController < ApplicationController
  before_action :set_asset, only: %i[show update destroy]

  def index
    @assets = Asset.all

    render json: @assets
  end

  def show
    render json: @asset
  end

  def create
    @asset = Asset.new(asset_params)

    if @asset.save
      render json: @asset, status: :created, location: @asset
    else
      render json: @asset.errors, status: :unprocessable_entity
    end
  end

  def update
    if @asset.update(asset_params)
      render json: @asset
    else
      render json: @asset.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @asset.destroy
  end

  private

  def set_asset
    @asset = Asset.find(params[:id])
  end

  def asset_params
    pp params
    params.require(:asset).permit(:name, :description, :bucket_url)
  end
end
