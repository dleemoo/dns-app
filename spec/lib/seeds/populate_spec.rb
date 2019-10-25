# frozen_string_literal: true

require "rails_helper"
require "seeds/populate"

RSpec.describe Seeds::Populate do
  # this is a small check to detect something very wrong with the basic seeds
  it "creates the expected number of records" do
    expect { Seeds::Populate.call }
      .to change(DnsRecord.joins(:hosts), :count).by(14)
  end
end
