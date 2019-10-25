# frozen_string_literal: true

class Host < ApplicationRecord
  has_many :dns_record_hosts
  has_many :dns_records, through: :dns_record_hosts
end
