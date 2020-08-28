# frozen_string_literal: true

require 'view/game/buy_companies'
require 'view/game/buy_trains'
require 'view/game/company'
require 'view/game/corporation'
require 'view/game/player'
require 'view/game/dividend'
require 'view/game/issue_shares'
require 'view/game/map'
require 'view/game/route_selector'
require 'view/game/cash_crisis'

module View
  module Game
    module Round
      class Operating < Snabberb::Component
        needs :game

        def render
          round = @game.round
          @step = round.active_step
          entity = @step.current_entity
          @current_actions = round.actions_for(entity)
          entity = entity.owner if entity.company?

          left = []
          left << h(RouteSelector) if @current_actions.include?('run_routes')
          left << h(Dividend) if @current_actions.include?('dividend')

          if @current_actions.include?('buy_train')
            left << h(IssueShares) if @current_actions.include?('sell_shares')
            left << h(BuyTrains)
          elsif @current_actions.include?('sell_shares') && entity.player?
            left << h(CashCrisis)
          end
          left << h(IssueShares) if @current_actions.include?('buy_shares')

          if entity.player?
            left << h(Player, player: entity, game: @game)
          elsif entity.operator? && @game.active_players.include?(entity.owner)
            left << h(Corporation, corporation: entity)
          end

          if round.current_entity.company? && round.active_entities.one?
            company = round.current_entity

            left << h(Company, company: company)

            if company.abilities(:assign_corporation)
              props = {
                style: {
                  display: 'inline-block',
                  verticalAlign: 'top',
                },
              }

              @step.assignable_corporations(company).each do |corporation|
                left << h(:div, props, [h(Corporation, corporation: corporation, selected_company: company)])
              end
            end
          end

          div_props = {
            style: {
              display: 'flex',
            },
          }
          right = [h(Map, game: @game)]
          right << h(:div, div_props, [h(BuyCompanies, limit_width: true)]) if @current_actions.include?('buy_company')

          left_props = {
            style: {
              overflow: 'hidden',
              verticalAlign: 'top',
            },
          }

          right_props = {
            style: {
              maxWidth: '100%',
              width: 'max-content',
            },
          }

          children = [
            h('div#left.inline-block', left_props, left),
            h('div#right.inline-block', right_props, right),
          ]

          h(:div, children)
        end
      end
    end
  end
end
