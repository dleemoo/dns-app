# frozen_string_literal: true

module CallInterface
  def self.included(base)
    base.class_eval do
      extend  ClassMethods
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)
    end
  end

  module ClassMethods
    def call(input)
      new.call(input)
    end
  end
end
