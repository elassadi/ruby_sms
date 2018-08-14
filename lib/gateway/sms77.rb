require 'net/http'
require 'net/https'
require 'uri'

module RubySms
  module Gateway
    class Sms77
      attr_accessor :api_key, :user

      SMS77_GATEWAY_URL = 'https://gateway.sms77.io/api/sms'.freeze
      SUCCESS_CODE	= '100'.freeze
      DEFAULT_PIN_SIZE	= 4

      def initialize(options)
        return if options.nil?
        options.symbolize_keys!
        return if options[:user].nil?
        return if options[:api_key].nil?

        self.user = options[:user]
        self.api_key = options[:api_key]
      end

      def send(options)
        return if options.nil?
        options.symbolize_keys!

        response = Sms77Response.new
        (response.add_error(:empty_options) and (return response)) if options.nil?
        code = post_request(options)
        return response if code == SUCCESS_CODE
        response.add_error(code)
        response
      end

      # generate a simple random 4 digits pin
      def send_pin(options)
        return if options.nil?
        options.symbolize_keys!

        response = Sms77Response.new
        (response.add_error(:empty_options) and (return response)) if options.nil?
        # we may use SecureRandom.hex(size) if you need a more secure pin
        response.pin = rand.to_s[2..(DEFAULT_PIN_SIZE + 1)]
        options[:text] = options[:text].gsub('%PIN%', response.pin)
        code = post_request(options)
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
          from:  options[:from],
          to: 	 options[:to],
          delay: options[:delay] || 0,
          type:  options[:type] || 'direct',  # direct / economy
          flash: options[:flash] || 0,        # 0 / 1
          label:  options[:label],
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
