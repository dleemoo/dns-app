# frozen_string_literal: true

Rails.application.routes.draw do
  resources :dns_records, only: %i[index create]
end
