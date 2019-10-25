# frozen_string_literal: true

require "rails_helper"

RSpec.describe DnsRecordFactory do
  let(:factory) { described_class }

  context "invalid contracts" do
    it "denies missing parameters" do
      result = factory.call(nil)

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(
        ip: ["is missing"],
        hostname_attributes: ["is missing"]
      )
    end

    it "denies invalid parameters" do
      result = factory.call(ip: "10.3", hostname_attributes: 10)

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(
        ip: ["is in invalid format"],
        hostname_attributes: ["must be an array"]
      )
    end

    it "denies invalid parameters" do
      result = factory.call(ip: "10.3.3.1.", hostname_attributes: ["ok.com", 3])

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(
        ip: ["is in invalid format"],
        hostname_attributes: { 1 => ["must be a string"] }
      )
    end
  end

  context "with valid parameters" do
    it "creates the associated records" do
      expect { factory.call(ip: "1.1.1.1", hostname_attributes: %w[a.com b.com]) }
        .to change(DnsRecord, :count).by(1)
        .and change(Host, :count).by(2)
        .and change(DnsRecordHost, :count).by(2)

      dns_record = DnsRecord.find_by_ip("1.1.1.1")
      expect(dns_record.hosts.order(:name).pluck(:name)).to eq(%w[a.com b.com])
    end

    context "when some host already exists" do
      it "associated with existing host" do
        Host.create!(name: "a.com")

        expect { factory.call(ip: "1.1.1.1", hostname_attributes: %w[a.com b.com]) }
          .to change(DnsRecord, :count).by(1)
          .and change(Host, :count).by(1)
          .and change(DnsRecordHost, :count).by(2)

        dns_record = DnsRecord.find_by_ip("1.1.1.1")
        expect(dns_record.hosts.order(:name).pluck(:name)).to eq(%w[a.com b.com])
      end
    end

    context "when ip has present at database" do
      it "denies any creation" do
        DnsRecord.create!(ip: "1.1.1.1")

        result = factory.call(ip: "1.1.1.1", hostname_attributes: %w[a.com b.com])

        expect(result).to be_failure
        expect(result.failure).to eq("DnsRecord already present")
      end
    end
  end
end
