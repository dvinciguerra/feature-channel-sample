# frozen_string_literal: true

class EmailsController < ApplicationController
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
      render json: @email, status: :created, location: @email
    else
      render json: @email.errors, status: :unprocessable_entity
    end
  end

  def update
    if @email.update(email_params)
      render json: @email
    else
      render json: @email.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @email.destroy
  end

  private

  def set_email
    @email = Email.find(params[:id])
  end

  def email_params
    params.require(:email).permit(:name, :subject, :body, :asset_id)
  end
end
