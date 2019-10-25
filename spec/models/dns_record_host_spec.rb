# frozen_string_literal: true

require "rails_helper"

RSpec.describe DnsRecordHost, type: :model do
  let(:host) { Host.create!(name: "my-host.com") }
  let(:dns_record) { DnsRecord.create!(ip: "1.1.1.1") }

  it "creates a record with valid attributes" do
    expect { DnsRecordHost.create!(host: host, dns_record: dns_record) }
      .to change(DnsRecordHost, :count).by(1)
  end

  context "database constraints" do
    it "raises a exception for invalid dns_record association" do
      expect { DnsRecordHost.create!(dns_record_id: SecureRandom.uuid, host: host) }
        .to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Dns record must exist/)
    end

    it "raises a exception for invalid host association" do
      expect { DnsRecordHost.create!(dns_record: dns_record, host_id: SecureRandom.uuid) }
        .to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Host must exist/)
    end

    it "raises a excpetion for duplicated host-dns association" do
      DnsRecordHost.create!(host: host, dns_record: dns_record)

      expect { DnsRecordHost.create!(host: host, dns_record: dns_record) }
        .to raise_error(ActiveRecord::RecordNotUnique, /duplicate key value violates unique constraint \"unique-dns-association\"/)
    end
  end
end
