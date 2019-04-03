module ADDSTalker
  class METAR
    module Wind
      attr_accessor :wind

      def wind_variable?
        @wind&.dig(:wind, :variable) ? true : false
      end

      def wind_variable_first
        @wind&.dig(:wind, :wind_variable_first)
      end

      def wind_variable_second
        @wind&.dig(:wind, :wind_variable_seconds)
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

      def check_wind_variable
        return nil unless raw_text

        raw_text_array = raw_text.split
        wind_group_index = raw_text_array.index do |group|
          group.chars.last(2).join == 'KT'
        end
        return nil unless wind_group_index

        hash = {}
        wind_group = raw_text_array[wind_group_index]
        follow_group = raw_text_array[wind_group_index + 1]
        if wind_group.include?('VRB')
          hash[:variable] = true
          hash[:direction] = nil
        end
        if follow_group.include?('V')
          variable_bound_array = follow_group.split('V')
          hash[:variable_first] = variable_bound_array[0]
          hash[:variable_second] = variable_bound_array[1].max
        end
        return nil if hash.empty?
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
    end
  end
end
