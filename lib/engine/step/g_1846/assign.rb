# frozen_string_literal: true

require_relative '../assign'

module Engine
  module Step
    module G1846
      class Assign < Assign
        def assignable_corporations(company = nil)
          super + @game.minors.reject { |m| m.assigned?(company&.id) }
        end
      end
    end
  end
end
