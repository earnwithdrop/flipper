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

          instrument_update(
            feature_flag_name: feature_name,
            gate_name: 'boolean',
            value: 'N/A',
            operation: params['action'] == 'Enable' ? 'enable' : 'disable'
          )

          redirect_to "/features/#{@feature.key}"
        end
      end
    end
  end
end
