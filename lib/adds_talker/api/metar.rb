# frozen_string_literal: true

require_relative 'helper'

module ADDSTalker
  module API
    module METAR
      def get_metar(station_id:, starting:, ending: nil, most_recent: true)
        params = { dataSource: 'metars' }
        params[:stationString] = if station_id.is_a?(Array)
                                   station_id.join(',')
                                 else
                                   station_id
                                 end
        if starting || ending
          params.merge!(ADDSTalker::API::Helper.time_to_parameter(starting, ending))
        end
        params.merge!(ADDSTalker::API::Helper
                        .most_recent_to_parameter(most_recent, ending))
        response = get(request_params: params)
        response.body['response']
      end
    end
  end
end
