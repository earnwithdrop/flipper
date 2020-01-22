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

            datadog&.event 'Flipper Feature Updated',
                           "The feature flag `#{feature_name}` had percentage of actors gate updated to `#{params['value']}`.",
                           source_type_name: 'flipper',
                           tags: %W[env:#{ENV['RACK_ENV']}]
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
