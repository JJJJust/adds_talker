# frozen_string_literal: true

require_relative 'api/client'

module ADDSTalker
  class METAR
    APIMAP = { station_id: :station, metar_type: :type }.freeze
    attr_accessor :station
    attr_accessor :latitude
    attr_accessor :longitude
    attr_accessor :elevation
    attr_accessor :type
    attr_accessor :observation_time
    attr_accessor :temperature
    attr_accessor :dewpoint
    attr_accessor :wind
    attr_accessor :visibility
    attr_accessor :altimeter
    attr_accessor :sea_level_pressure
    attr_accessor :flight_category
    attr_accessor :wx_string
    attr_reader :sky_condition
    attr_accessor :pressure_tendency
    attr_accessor :max_t
    attr_accessor :min_t
    attr_accessor :precipitation
    attr_accessor :snow
    attr_accessor :vertical_visibility
    attr_accessor :automated
    attr_accessor :auto_station
    attr_accessor :maintenance_indicator
    attr_accessor :no_signal
    attr_accessor :lightning_sensor_off
    attr_accessor :freezing_rain_sensor_off
    attr_accessor :present_weather_sensor_off
    attr_accessor :raw_text
    attr_accessor :unhandled

    # Creates a METAR object based on a Hash returned from the
    # METAR::API::Client.
    #
    # @param input [Hash]
    # @return [Array]
    def self.parse_from_data(input)
      object = new
      input.select { |k, _v| APIMAP.key?(k.to_sym) }.each_key do |k|
        object.send("#{APIMAP[k.to_sym]}=", input.delete(k))
      end
      input.reject { |k, _v| object.respond_to?("#{k}=", true) }
        .each_key do |k|
        object.unhandled ||= {}
        object.unhandled.merge!(k => input.delete(k))
      end
      input.each_key do |k|
        object.send("#{k}=", input.delete(k))
      end
      object
    end

    # Retrieves a METAR.
    #
    # @param station [String, Array]
    # @param starting [#to_i]
    # @param ending [#to_i]
    # @param most_recent [True, False]
    # @return [Array<ADDSTalker::METAR>]
    def self.get(station:, starting:, ending: nil, most_recent: true)
      raise StandardError unless station.is_a?(String) || station.is_a?(Array)

      client = ADDSTalker::API::Client.new
      response = client.get_metar(station_id: station, starting: starting,
                                  ending: ending, most_recent: most_recent)
      raise StandardError if response['data']['num_results'].to_i <= 0

      data = response['data']['METAR']
      data = [data] if data.is_a?(Hash)
      result_array = []
      data.each do |metar_hash|
        result_array << parse_from_data(metar_hash)
      end
      raise StandardError if result_array.empty?

      result_array
    end

    private

    def temp_c=(value)
      @temperature = { value: Float(value), unit: :celsius }
    end

    def dewpoint_c=(value)
      @dewpoint = { value: Float(value), unit: :celsius }
    end

    def wind_dir_degrees=(value)
      hash = { direction: value.to_i }
      @wind = if @wind
                if @wind[:wind]
                  @wind.merge(wind: @wind[:wind].merge(hash))
                else
                  @wind.merge(wind: hash)
                end
              else
                { wind: hash }
              end
    end

    def wind_speed_kt=(value)
      hash = { speed: value.to_i, unit: :knot }
      @wind = if @wind
                if @wind[:wind]
                  @wind.merge(wind: @wind[:wind].merge(hash))
                else
                  @wind.merge(wind: hash)
                end
              else
                { wind: hash }
              end
    end

    def wind_gust_kt=(value)
      hash = { value: value.to_i, unit: :knot }

      @wind = if @wind
                if @wind[:gusting]
                  @wind.merge(gusting: @wind[:gusting].merge(hash))
                else
                  @wind.merge(gusting: hash)
                end
              else
                { gusting: hash }
              end
    end

    def visibility_statute_mi=(value)
      @visibility = { value: Float(value), unit: :statute_mile }
    end

    def altim_in_hg=(value)
      @altimeter = { value: Float(value), unit: :inch_of_mercury }
    end

    def sea_level_pressure_mb=(value)
      @sea_level_pressure = { value: Float(value), unit: :millibar }
    end

    def precip_in=(value)
      hash = { since_last: { value: Float(value), units: :inch } }
      @preciptation = if @preciptation
                        @preciptation.merge(hash)
                      else
                        hash
                      end
    end

    # TODO: Lookup hash for sky condition
    def sky_condition=(value)
      value = [value] if value.is_a?(Hash)

      hash = {}
      value.each do |h|
        hash.merge!(h['cloud_base_ft_agl'].to_i => h['sky_cover'])
      end
      @sky_condition = hash
    end

    def elevation_m=(value)
      @elevation = { value: Float(value), unit: :meter }
    end

    # noinspection RubyInstanceMethodNamingConvention
    # rubocop:disable Naming/MethodName
    def maxT_c=(value)
      @max_t = { value: Float(value), unit: :celsius }
    end
    # rubocop:enable Naming/MethodName

    # noinspection RubyInstanceMethodNamingConvention
    # rubocop:disable Naming/MethodName
    def minT_c=(value)
      @min_t = { value: Float(value), unit: :celsius }
    end
    # rubocop:enable Naming/MethodName

    QCVALUES = { corrected: :corrected, auto: :automated,
                 auto_station: :auto_station,
                 maintenance_indicator: :maintenance_indicator,
                 lightning_sensor_off: :lightning_sensor_off,
                 freezing_rain_sensor_off: :freezing_rain_sensor_off,
                 present_weather_sensor_off: :present_weather_sensor_off }
                 .freeze

    def quality_control_flags=(value)
      value = [value] if value.is_a?(Hash)

      value.each do |hash|
        hash.each_key do |k|
          send("#{QCVALUES[k.to_sym]}=", true)
        end
      end
    end
  end
end
