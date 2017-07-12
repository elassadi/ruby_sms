require 'rubygems'
require 'logger'
require 'gateway/sms77'
require 'gateway/response'

module RubySms
  class << self
    def logger
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::ERROR
      @logger
    end

    def logger=(log_instance)
      raise ArgumentError, 'Logger parameter must be a Logger object' unless log_instance.is_a?(Logger)
      @logger = log_instance
    end

    def new(options = {})
      case options[:gw]
      when :sms99
        'NOT IMPLEMENTED'
      else
        RubySms::Gateway::Sms77.new(options)
      end
    end
  end
end
