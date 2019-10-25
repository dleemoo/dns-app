# frozen_string_literal: true

class ApplicationController < ActionController::API
  def render_success(data, status = :ok)
    render status: status, json: data
  end

  def render_failure(errors, status: :unprocessable_entity)
    render status: status, json: { errors: errors }
  end
end
