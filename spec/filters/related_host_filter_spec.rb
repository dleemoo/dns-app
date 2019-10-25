# frozen_string_literal: true

require "rails_helper"

RSpec.describe RelatedHostFilter, type: :filter do
  let(:filter) { described_class }

  context "invalid contracts" do
    it "denies missing parameters" do
      result = filter.call(nil)

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(
        hosts: ["is missing"],
        scope: ["is missing"]
      )
    end

    it "denies invalid parameters" do
      result = filter.call(hosts: [1, 2], scope: nil)

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(
        scope: ["must be ActiveRecord::Relation"],
        hosts: { 0 => ["must be a string"], 1 => ["must be a string"] }
      )
    end
  end

  context "with default scenario present" do
    before { create_default_scenario }

    context "when filter is not present and scope does not restrict results" do
      it "returns all records" do
        result = filter.call(hosts: [], scope: DnsRecord.unscoped)

        expect(result).to be_success

        response = JSON(result.value![:entries].to_json)

        %w[lorem.com dolor.com amet.com ipsum.com sit.com].each do |host|
          id = Host.find_by_name(host).id
          expect(response).to include("id" => id, "name" => host, "count" => DnsRecordHost.where(host_id: id).count)
        end
      end
    end

    context "when filter is not present and scope restrict results" do
      it "returns only records that match the scope" do
        scope = DnsRecord.where(ip: %w[1.1.1.1 2.2.2.2])
        result = filter.call(hosts: [], scope: scope)

        expect(result).to be_success

        response = JSON(result.value![:entries].to_json)
        scoped_count = DnsRecordHost.where(dns_record_id: scope)

        %w[lorem.com dolor.com amet.com ipsum.com].each do |host|
          id = Host.find_by_name(host).id
          expect(response).to include("id" => id, "name" => host, "count" => scoped_count.where(host_id: id).count)
        end
      end
    end

    context "when filter is present and scope does not restrict results" do
      it "returns only records that match the scope" do
        result = filter.call(hosts: %w[sit.com], scope: DnsRecord.unscoped)

        expect(result).to be_success

        response = JSON(result.value![:entries].to_json)

        %w[lorem.com dolor.com amet.com ipsum.com].each do |host|
          id = Host.find_by_name(host).id
          expect(response).to include("id" => id, "name" => host, "count" => DnsRecordHost.where(host_id: id).count)
        end
      end
    end

    context "when filter is present and scope restrict results" do

      it "returns only records that match the scope" do
        scope = DnsRecord.where(ip: %w[1.1.1.1 2.2.2.2 3.3.3.3])
        result = filter.call(hosts: %w[sit.com], scope: scope)

        expect(result).to be_success

        response = JSON(result.value![:entries].to_json)

        scoped_count = DnsRecordHost.where(dns_record_id: scope)

        %w[lorem.com dolor.com amet.com ipsum.com].each do |host|
          id = Host.find_by_name(host).id
          expect(response).to include("id" => id, "name" => host, "count" => scoped_count.where(host_id: id).count)
        end
      end

      it "returns empty result if filter and scope are mutually exclusive" do
        result = filter.call(hosts: %w[ipsum.com], scope: DnsRecord.where(ip: %w[2.2.2.2]))

        expect(result).to be_success

        response = JSON(result.value![:entries].to_json)

        expect(response).to be_empty
      end
    end
  end
end
