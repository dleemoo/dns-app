# frozen_string_literal: true

require "rails_helper"

RSpec.describe DnsRecordInfo do
  include SpecGroup::Filter::HelperMethods
  let(:service) { described_class }

  context "contracts" do
    it "denies invalid parameters" do
      result = service.call(included: 10, excluded: [{}])

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(
        included: ["must be an array"],
        excluded: { 0 => ["must be a string"] }
      )
    end

    it "accepts blank parameters to match API restrictions" do
      result = service.call({})

      expect(result).to be_success

      # expect an empty response since there is not records at database
      expect(result.value!.to_h).to eq(total_records: 0, records: [], related_hostnames: [])
    end
  end

  context "with default scenario present" do
    before { create_default_scenario }

    it "connects the filters response as expected by API" do
      result = service.call({})

      expect(result).to be_success

      response = JSON(result.value!.to_json)

      expect(response["total_records"]).to eq(5)

      %w[1.1.1.1 2.2.2.2 3.3.3.3 4.4.4.4 5.5.5.5].each do |ip|
        expect(response["records"]).to include(
          "id" => DnsRecord.find_by_ip(ip).id, "ip" => ip
        )
      end

      %w[amet.com lorem.com dolor.com sit.com ipsum.com].each do |host|
        expect(response["related_hostnames"]).to include(
          "name" => host, "count" => DnsRecordHost.joins(:host).where(hosts: { name: host }).count
        )
      end
    end
  end
end
