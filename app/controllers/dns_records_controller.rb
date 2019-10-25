# frozen_string_literal: true

class DnsRecordsController < ApplicationController
  def index
    DnsRecordInfo.call(filter_params)
      .fmap { |records| render_success(records) }
      .or   { |failure| render_failure(failure.errors.to_h) }
  end

  def create
    DnsRecordFactory.call(create_params)
      .fmap { |record| render_success({ id: record.id }, :created) }
      .or   { |failure| render_failure(failure.errors.to_h) }
  end

  private

  def filter_params
    params.permit(included: [], excluded: []).to_h
  end

  def create_params
    params.require(:dns_records).permit(:ip, hostname_attributes: []).to_h
  end
end
