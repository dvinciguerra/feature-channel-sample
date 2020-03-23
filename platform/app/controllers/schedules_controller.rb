# frozen_string_literal: true

class SchedulesController < ApplicationController
  FEATURE_CHANNEL = 'feature_channel'

  before_action :set_schedule, only: %i[show update destroy]

  def index
    @schedules = Schedule.all

    render json: @schedules
  end

  def show
    render json: @schedule
  end

  def create
    @schedule = Schedule.new(schedule_params)

    if @schedule.save
      redis_instance.publish(
        FEATURE_CHANNEL,
        service: 'platform',
        feature: 'schedules',
        id: @schedule.id.to_s,
        type: 'CREATE'
      )
      render json: @schedule, status: :created, location: @schedule
    else
      render json: @schedule.errors, status: :unprocessable_entity
    end
  end

  def update
    if @schedule.update(schedule_params)
      redis_instance.publish(
        FEATURE_CHANNEL,
        service: 'platform',
        feature: 'schedules',
        id: @schedule.id.to_s,
        type: 'UPDATE'
      )
      render json: @schedule
    else
      render json: @schedule.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @schedule.destroy
      redis_instance.publish(
        FEATURE_CHANNEL,
        service: 'platform',
        feature: 'schedules',
        id: @schedule.id.to_s,
        type: 'DELETE'
      )
    end
  end

  private

  def redis_instance
    @redis ||= Redis.new
  end

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end

  def schedule_params
    params.require(:schedule).permit(:name, :description, :email_id)
  end
end
