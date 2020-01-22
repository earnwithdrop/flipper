require 'flipper/ui/action'
require 'flipper/ui/decorators/feature'

module Flipper
  module UI
    module Actions
      class BooleanGate < UI::Action
        include FeatureNameFromRoute

        route %r{\A/features/(?<feature_name>.*)/boolean/?\Z}

        def post
          feature = flipper[feature_name]
          @feature = Decorators::Feature.new(feature)

          if params['action'] == 'Enable'
            feature.enable
          else
            feature.disable
          end

          action_string = params['action'] == 'Enable' ? 'enabled' : 'disabled'

          datadog&.event 'Flipper Feature Updated',
                         "The feature flag `#{feature_name}` has been updated to #{action_string}.",
                         source_type_name: 'flipper',
                         tags: %W[env:#{ENV['RACK_ENV']}]

          redirect_to "/features/#{@feature.key}"
        end
      end
    end
  end
end
