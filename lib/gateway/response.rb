module RubySms
  module Gateway
    class Response
      attr_accessor :errors
      def initialize
        self.errors = []
      end

      def success?
        errors.empty?
      end
    end

    class Sms77Response < Response
      attr_accessor :pin
      SMS77_ERROR_CODES = {
        '100' => '100: SMS delivered successfully',
        '101' => '101: Delivery to at least one recipient failed',
        '201' => '201: Sender illegal',
        '202' => '202: Recipient number illegal',
        '300' => '300: Missing username or password',
        '301' => '301: Argument "to" missing',
        '304' => '304: Argument "type" missing',
        '305' => '305: Argument "text" missing',
        '306' => '306: Sender number illegal',
        '307' => '307: Argument "url" missing',
        '400' => '400: Argument "type" invalid',
        '401' => '401: Argument "text" too long',
        '402' => '402: Reload lock - same SMS sent within 90 seconds',
        '500' => '500: Not enough credits',
        '600' => '600: Carrier delivery failed',
        '700' => '700: Unknown error',
        '801' => '801: Logo file not set',
        '802' => '802: Logo file does not exist',
        '803' => '803: Ring tone not set',
        '900' => '900: Given credentials not valid',
        '901' => '901: Message ID invalid',
        '902' => '902: HTTP API not activated for this account',
        '903' => '903: Server IP invalid',
        '11' => '11: SMS carrier temporarily not available',
        '0' => 'Error: Status code does not exist'
      }.freeze

      def add_error(error_code, _options = {})
        error_message = SMS77_ERROR_CODES[error_code] || error_code.to_s
        errors << error_message
      end
    end
  end
end
