# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require_relative 'metar'

module ADDS
  module API
    class Client
      include ADDS::API::METAR
      attr_accessor :url
      attr_accessor :persistent_parameters
      attr_accessor :connection

      def initialize(url: 'https://www.aviationweather.gov/adds/' \
                             'dataserver_current/httpparam',
                     persistent_params: nil)
        @url = url
        @persistent_params = { requestType: 'retrieve',
                               format: 'xml' }
        @persistent_params.merge!(persistent_params) if persistent_params
        @connection ||= Faraday.new do |conn|
          conn.response :xml, content_type: /\bxml$/
          conn.adapter Faraday.default_adapter
        end
      end

      def get(request_params: nil)
        merged_params = if request_params
                          @persistent_params.merge(request_params)
                        else
                          @persistent_params
                        end
        params = merged_params.delete_if { |_k, v| v.nil? }
        response = @connection.get(@url, params)
        raise StandardError unless response.body['response']['errors'].nil?

        response
      end
    end
  end
end
