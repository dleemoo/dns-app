# frozen_string_literal: true

require "rails_helper"

RSpec.describe Host, type: :model do
  it "creates a record with valid attributes" do
    expect { Host.create!(name: "some-domain.com") }
      .to change(Host, :count).by(1)
  end

  context "database constraints" do
    it "raises a exception for duplicated names" do
      Host.create!(name: "some-domain.com")

      expect { Host.create!(name: "some-domain.com") }
        .to raise_error(ActiveRecord::RecordNotUnique, /duplicate key value violates unique constraint "unique-host-name"/)
    end

    it "raises a exception for duplicated names ignoring the case" do
      Host.create!(name: "some-DOMAIN.com")

      expect { Host.create!(name: "SOME-domain.com") }
        .to raise_error(ActiveRecord::RecordNotUnique, /duplicate key value violates unique constraint "unique-host-name"/)
    end
  end
end
