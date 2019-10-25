# frozen_string_literal: true

module SpecGroup
  module Filter
    RSpec.configure do |config|
      config.include self, type: :filter
    end

    def self.included(base)
      base.include HelperMethods
    end

    module HelperMethods
      def create_default_scenario
        require "seeds/populate"
        Seeds::Populate.call
      end
    end
  end
end
