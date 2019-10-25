# frozen_string_literal: true

class DnsRecordHost < ApplicationRecord
  belongs_to :dns_record
  belongs_to :host
end
