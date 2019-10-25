# frozen_string_literal: true

require "rails_helper"

RSpec.describe DnsRecord, type: :model do
  it "creates a record with valid attributes" do
    expect { DnsRecord.create!(ip: "1.1.1.1") }
      .to change(DnsRecord, :count).by(1)
  end

  context "database constraints" do
    it "raises a exception for duplicated ips" do
      DnsRecord.create!(ip: "1.1.1.1")

      expect { DnsRecord.create!(ip: "1.1.1.1") }
        .to raise_error(ActiveRecord::RecordNotUnique, /duplicate key value violates unique constraint "index_dns_records_on_ip"/)
    end
  end
end
