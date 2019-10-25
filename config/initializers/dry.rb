# frozen_string_literal: true

require "dry/schema"
require "dry/monads"
require "dry/monads/do"

Dry::Schema.load_extensions(:monads)
