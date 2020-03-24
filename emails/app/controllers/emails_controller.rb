# frozen_string_literal: true

class EmailsController < ApplicationController
  FEATURE_CHANNEL = 'feature_channel'

  before_action :set_email, only: %i[show update destroy]

  def index
    @emails = Email.all

    render json: @emails
  end

  def show
    render json: @email
  end

  def create
    @email = Email.new(email_params)

    if @email.save
      redis_instance.publish(
        FEATURE_CHANNEL,
        {
          service: 'emails',
          feature: 'emails',
          id: @email.id.to_s,
          type: 'CREATE'
        }.to_msgpack
      )
      render json: @email, status: :created, location: @email
    else
      render json: @email.errors, status: :unprocessable_entity
    end
  end

  def update
    if @email.update(email_params)
      redis_instance.publish(
        FEATURE_CHANNEL,
        {
          service: 'emails',
          feature: 'emails',
          id: @email.id.to_s,
          type: 'UPDATE'
        }.to_msgpack
      )
      render json: @email
    else
      render json: @email.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @email.destroy
      redis_instance.publish(
        FEATURE_CHANNEL,
        {
          service: 'emails',
          feature: 'emails',
          id: @email.id.to_s,
          type: 'DELETE'
        }.to_msgpack
      )
    end
  end

  private

  def redis_instance
    @redis ||= Redis.new
  end

  def set_email
    @email = Email.find(params[:id])
  end

  def email_params
    params.require(:email).permit(:name, :subject, :body, :asset_id)
  end
end
