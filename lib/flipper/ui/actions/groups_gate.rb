require 'flipper/ui/action'
require 'flipper/ui/decorators/feature'

module Flipper
  module UI
    module Actions
      class GroupsGate < UI::Action
        include FeatureNameFromRoute

        route %r{\A/features/(?<feature_name>.*)/groups/?\Z}

        def get
          feature = flipper[feature_name]
          @feature = Decorators::Feature.new(feature)

          breadcrumb 'Home', '/'
          breadcrumb 'Features', '/features'
          breadcrumb @feature.key, "/features/#{@feature.key}"
          breadcrumb 'Add Group'

          view_response :add_group
        end

        def post
          feature = flipper[feature_name]
          value = params['value'].to_s.strip

          if Flipper.group_exists?(value)
            case params['operation']
            when 'enable'
              feature.enable_group value
            when 'disable'
              feature.disable_group value
            end

            datadog&.event 'Flipper Feature Updated',
                           "The feature flag `#{feature_name}` had group `#{value}` #{params['operation']}d.",
                           source_type_name: 'flipper',
                           tags: %W[env:#{ENV['RACK_ENV']}]

            redirect_to("/features/#{feature.key}")
          else
            error = Rack::Utils.escape("The group named #{value.inspect} has not been registered.")
            redirect_to("/features/#{feature.key}/groups?error=#{error}")
          end
        end
      end
    end
  end
end
