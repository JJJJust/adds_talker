# frozen_string_literal: true

require 'time'

module ADDS
  module API
    module Helper
      # @param starting [#to_i]
      # @param ending [#to_i]
      def self.time_to_parameter(starting, ending = nil)
        raise ArgumentError unless starting.respond_to?('to_i')

        return_value = if ending
                         raise ArgumentError unless ending.respond_to?('to_i')

                         { startTime: starting.to_i, endTime: ending.to_i }
                       else
                         seconds_ago = (Time.now.to_i - starting.to_i)
                         hours_ago = seconds_ago.fdiv(3600).ceil(2)
                         { hoursBeforeNow: hours_ago }
                       end
        return_value
      end

      def self.most_recent_to_parameter(most_recent, end_time)
        return_value = if most_recent
                         if end_time
                           'postfilter'
                         else
                           'constraint'
                         end
                       else
                         'false'
                       end
        { mostRecentForEachStation: return_value }
      end
    end
  end
end
