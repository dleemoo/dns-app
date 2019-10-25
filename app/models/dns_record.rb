# frozen_string_literal: true

class DnsRecord < ApplicationRecord
  has_many :dns_record_hosts
  has_many :hosts, through: :dns_record_hosts
end
