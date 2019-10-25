# frozen_string_literal: true

require "rails_helper"

RSpec.describe DnsRecordFilter, type: :filter do
  let(:filter) { described_class }

  context "invalid contracts" do
    it "denies missing parameters" do
      result = filter.call(nil)

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(
        included: ["is missing"],
        excluded: ["is missing"]
      )
    end

    it "denies invalid parameters" do
      result = filter.call(included: nil, excluded: [10, 11])

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(
        included: ["must be an array"],
        excluded: { 0 => ["must be a string"], 1 => ["must be a string"] }
      )
    end
  end

  context "with default scenario present" do
    before { create_default_scenario }

    context "when filter isn't present" do
      it "returns all records" do
        result = filter.call(included: [], excluded: [])

        expect(result).to be_success
        expect(result.value![:total_records]).to eq(5)

        response = JSON(result.value![:entries].to_json)

        %w[1.1.1.1 2.2.2.2 3.3.3.3 4.4.4.4 5.5.5.5].each do |ip|
          id = DnsRecord.find_by_ip(ip).id
          expect(response).to include("id" => id, "ip" => ip)
        end
      end
    end

    context "when only included filter is present" do
      it "returns matching records only" do
        result = filter.call(included: %w[ipsum.com dolor.com], excluded: [])

        expect(result).to be_success
        expect(result.value![:total_records]).to eq(3)

        response = JSON(result.value![:entries].to_json)

        %w[1.1.1.1 3.3.3.3 4.4.4.4].each do |ip|
          id = DnsRecord.find_by_ip(ip).id
          expect(response).to include("id" => id, "ip" => ip)
        end

        %w[2.2.2.2 5.5.5.5].each do |ip|
          id = DnsRecord.find_by_ip(ip).id
          expect(response).not_to include("id" => id, "ip" => ip)
        end
      end
    end

    context "when only excluded filter is present" do
      it "returns matching records only" do
        result = filter.call(included: [], excluded: %w[sit.com])

        expect(result).to be_success
        expect(result.value![:total_records]).to eq(3)

        response = JSON(result.value![:entries].to_json)

        %w[1.1.1.1 2.2.2.2 3.3.3.3].each do |ip|
          id = DnsRecord.find_by_ip(ip).id
          expect(response).to include("id" => id, "ip" => ip)
        end

        %w[4.4.4.4 5.5.5.5].each do |ip|
          id = DnsRecord.find_by_ip(ip).id
          expect(response).not_to include("id" => id, "ip" => ip)
        end
      end
    end

    context "when included and excluded filters are present" do
      it "returns matching records only" do
        result = filter.call(included: %w[ipsum.com dolor.com], excluded: %w[sit.com])

        expect(result).to be_success
        expect(result.value![:total_records]).to eq(2)

        response = JSON(result.value![:entries].to_json)

        %w[1.1.1.1 3.3.3.3].each do |ip|
          id = DnsRecord.find_by_ip(ip).id
          expect(response).to include("id" => id, "ip" => ip)
        end

        %w[2.2.2.2 4.4.4.4 5.5.5.5].each do |ip|
          id = DnsRecord.find_by_ip(ip).id
          expect(response).not_to include("id" => id, "ip" => ip)
        end
      end
    end
  end
end
