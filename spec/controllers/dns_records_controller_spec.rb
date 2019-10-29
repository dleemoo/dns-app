# frozen_string_literal: true

require "rails_helper"

RSpec.describe DnsRecordsController, type: :controller do
  describe "GET #index" do
    it "delegates the execution to DnsRecordInfo service" do
      get :index
      expect(response).to have_http_status(:success)
      expect(JSON(response.body)).to eq(
        "total_records" => 0, "records" => [], "related_hostnames" => []
      )
    end
  end

  describe "GET #create" do
    context "with valid parameters" do
      it "creates the records and returns DnsRecord id" do
        post :create, params: {
          dns_records: {
            ip: "1.1.1.1",
            hostname_attributes: [
              "a.com",
              "b.com"
            ]
          }
        }

        expect(response).to have_http_status(:created)
        dns_record = DnsRecord.find(JSON(response.body)["id"])
        expect(dns_record.hosts.order(:name).pluck(:name)).to eq(%w[a.com b.com])
      end
    end

    context "with invalid parameters" do
      it "returns the error information" do
        post :create, params: {
          dns_records: {
            ip: "1.1.1.",
            hostname_attributes: [
              "a.com",
              "b.com"
            ]
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON(response.body)).to eq(
          "errors" => { "ip" => ["is in invalid format"] }
        )
      end
    end

    context "with duplicated ip record" do
      it "returns the error information" do
        DnsRecord.create!(ip: "1.1.1.1")

        post :create, params: {
          dns_records: {
            ip: "1.1.1.1",
            hostname_attributes: [
              "a.com",
              "b.com"
            ]
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON(response.body)).to eq(
          "errors" => { "ip" => ["DnsRecord already present"] }
        )
      end
    end
  end
end
