# frozen_string_literal: true

class AssetsController < ApplicationController
  FEATURE_CHANNEL = 'feature_channel'

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
      redis_instance.publish(
        FEATURE_CHANNEL,
        {
          service: 'assets',
          feature: 'assets',
          id: @asset.id.to_s,
          type: 'CREATE'
        }.to_msgpack
      )
      render json: @asset, status: :created, location: @asset
    else
      render json: @asset.errors, status: :unprocessable_entity
    end
  end

  def update
    if @asset.update(asset_params)
      redis_instance.publish(
        FEATURE_CHANNEL,
        {
          service: 'assets',
          feature: 'assets',
          id: @asset.id.to_s,
          type: 'UPDATE'
        }.to_msgpack
      )
      render json: @asset
    else
      render json: @asset.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @asset.destroy
      redis_instance.publish(
        FEATURE_CHANNEL,
        {
          service: 'assets',
          feature: 'assets',
          id: @asset.id.to_s,
          type: 'DELETE'
        }.to_msgpack
      )
    end
  end

  private

  def redis_instance
    @redis ||= Redis.new
  end

  def set_asset
    @asset = Asset.find(params[:id])
  end

  def asset_params
    pp params
    params.require(:asset).permit(:name, :description, :bucket_url)
  end
end
