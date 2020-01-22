require 'flipper/ui/action'
require 'flipper/ui/decorators/feature'

module Flipper
  module UI
    module Actions
      class PercentageOfActorsGate < UI::Action
        include FeatureNameFromRoute

        route %r{\A/features/(?<feature_name>.*)/percentage_of_actors/?\Z}

        def post
          feature = flipper[feature_name]
          @feature = Decorators::Feature.new(feature)

          begin
            feature.enable_percentage_of_actors params['value']

            instrument_update(
              feature_flag_name: feature_name,
              gate_name: 'percentage_of_actors',
              value: params['value'],
              operation: 'enable'
            )
          rescue ArgumentError => exception
            error = Rack::Utils.escape("Invalid percentage of actors value: #{exception.message}")
            redirect_to("/features/#{@feature.key}?error=#{error}")
          end

          redirect_to "/features/#{@feature.key}"
        end
      end
    end
  end
end
