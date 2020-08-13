# frozen_string_literal: true

require_relative 'assign'

module Engine
  module Step
    module G1846
      class AssignSteamboat < G1846::Assign
        ACTIONS = %w[assign pass].freeze

        def actions(entity)
          blocking_for_steamboat? ? ACTIONS : super
        end

        def description
          'Assign Steamboat Company'
        end

        def assigned_hex
          @game.hexes.find { |h| h.assigned?(@company.id) }
        end

        def assigned_corp
          assignable_corporations.find { |c| c.assigned?(@company.id) }
        end

        def help
          assignments = [assigned_hex, assigned_corp].compact.map(&:name)

          targets = []
          targets << 'hex' if @company.abilities(:assign_hexes)
          targets << 'corporation or minor' if @company.abilities(:assign_corporation)

          help_text = ["#{@company.owner.name} may assign Steamboat Company to a new #{targets.join(' and/or ')}."]
          help_text << " Currently assigned to #{assignments.join(' and ')}." if assignments.any?

          help_text
        end

        def pass_description
          'Skip Assign'
        end

        def active_entities
          @company ? [@company] : super
        end

        def active?
          blocking_for_steamboat?
        end

        def blocking?
          blocking_for_steamboat? || super
        end

        def blocks?
          true
        end

        def pass!
          super
          @round.start_operating
        end

        def process_assign(action)
          super

          pass! if !@company.abilities(:assign_corporation) && !@company.abilities(:assign_hexes)
        end

        def process_pass(_action)
          if (ability = @company.abilities(:assign_hexes))
            ability.use!
            @log <<
              if (hex = assigned_hex)
                "Steamboat Company is assigned to #{hex.name}"
              else
                'Steamboat Company is not assigned to any hex'
              end
          end

          if (ability = @company.abilities(:assign_corporation))
            ability.use!
            @log <<
              if (corp = assigned_corp)
                "Steamboat Company is assigned to #{corp.name}"
              else
                'Steamboat Company is not assigned to any corporation or minor'
              end
          end

          pass!
        end

        def blocking_for_steamboat?
          if @game.steamboat.owned_by_player?
            company = @game.steamboat

            if company.abilities(:assign_corporation) || company.abilities(:assign_hexes)
              @company = company
              return true
            end
          end

          false
        end
      end
    end
  end
end
