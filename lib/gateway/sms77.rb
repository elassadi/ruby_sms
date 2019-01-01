require 'net/http'
require 'net/https'
require 'uri'

module RubySms
  module Gateway
    class Sms77
      class Parameters < Hash
        def initialize(options)
          merge!(options)
          symbolize_keys!
        end

        def symbolize_keys!
          inject({}){|h,(k,v)| h.merge({ k.to_sym => v}) }
        end
      end

      class ParameterError < StandardError ; end

      attr_accessor :api_key, :user

      SMS77_GATEWAY_URL = 'https://gateway.sms77.io/api/sms'.freeze
      SUCCESS_CODE	= '100'.freeze
      DEFAULT_PIN_SIZE	= 4

      def initialize(options)
        raise ParameterError, 'no params given' if options.nil?
        params = Parameters.new(options)
        raise ParameterError, 'parameter :user is missing' if params[:user].nil?
        raise ParameterError, 'parameter :api_key is missing' if params[:api_key].nil?

        self.user = params[:user]
        self.api_key = params[:api_key]
      end

      def send(options)
        raise ParameterError, 'no params given' if options.nil?
        params = Parameters.new(options)
        raise ParameterError, 'parameter :text is missing' if params[:text].nil?

        response = Sms77Response.new
        (response.add_error(:empty_options) and (return response)) if params.nil?
        code = post_request(params)
        return response if code == SUCCESS_CODE
        response.add_error(code)
        response
      end

      # generate a simple random 4 digits pin
      def send_pin(options)
        raise ParameterError, 'no params given' if options.nil?
        params = Parameters.new(options)
        raise ParameterError, 'parameter :text is missing' if params[:text].nil?

        response = Sms77Response.new
        (response.add_error(:empty_options) and (return response)) if params.nil?
        # we may use SecureRandom.hex(size) if you need a more secure pin
        response.pin = rand.to_s[2..(DEFAULT_PIN_SIZE + 1)]
        params[:text] = params[:text].gsub('%PIN%', response.pin)
        code = post_request(params)
        return response if code == SUCCESS_CODE
        response.add_error(code)
        response
      end

      private

      def post_request(options)
        uri = URI.parse(SMS77_GATEWAY_URL)
        request = Net::HTTP::Post.new(uri.to_s)
        request.set_form_data(
          text:  options[:text].force_encoding('utf-8'),
          to: 	 options[:to],
          delay: options[:delay] || 0,
          debug: 0,
          utf8:  1,
          u: user,
          p: api_key
        )
        response = https(uri).request(request)
        response.body
      rescue StandardError => e
        RubySms.logger.error("Error while sending post request => #{e}")
        :connection_error
      end

      def https(uri)
        Net::HTTP.new(uri.host, uri.port).tap do |http|
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end
    end
  end
end
