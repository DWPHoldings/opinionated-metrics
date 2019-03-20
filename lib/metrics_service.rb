# frozen_string_literal: true

##
# An object with methods for tracking basic, consistent metrics
class MetricsService
  ##
  # Must be set in application bootstrap before use
  LOGGER = nil

  ##
  # Track a basic event; intended for COUNT queries. Outputs `TrackedEvent`
  #
  # @param [String] name A name for filtering within WHERE queries
  def self.event(name, **additional_properties)
    properties = { name: name }.merge(additional_properties)
    ::NewRelic::Agent.record_custom_event('TrackedEvent', properties)
  end

  ##
  # Given a name and a block, tracks the milliseconds involved in processing the operation. Outputs `OpDurationMs`
  #
  # @param [String] name A name for filtering within WHERE queries
  def self.time_operation(name, **additional_properties)
    raise 'A block is required for time_operation calls' unless block_given?

    start = Time.current
    result = yield
    duration_start_end(name, start, Time.current, **additional_properties)
    result
  end

  ##
  # Given a name and a start/finish time, tracks the milliseconds involved in processing the operation. Outputs `OpDurationMs`
  #
  # @param [String] name A name for filtering within WHERE queries
  # @param [Time] start The start time of the operation
  # @param [Time] end The end time of the operation
  def self.duration_start_end(name, start, finish, **additional_properties)
    duration(name, (finish - start).seconds, **additional_properties)
  rescue StandardError => e
    LOGGER.error("Failed reporting duration to NewRelic: #{e}")
  end

  ##
  # Given a name and a duration, tracks the milliseconds involved in processing the operation. Outputs `OpDurationMs`
  #
  # @param [String] name A name for filtering within WHERE queries
  # @param [Time] start The start time of the operation
  # @param [Time] end The end time of the operation
  def self.duration(name, duration, **additional_properties)
    properties = { name: name, duration: duration.in_milliseconds }.merge(additional_properties)
    ::NewRelic::Agent.record_custom_event('OpDurationMs', properties)
  rescue StandardError => e
    LOGGER.error("Failed reporting duration to NewRelic: #{e}")
  end

  ##
  # Tracks an exception for error reporting when errors are suppressable for the purpose of HTTP status codes. Outputs `Error`
  #
  # @param [String] name A name for filtering within WHERE queries
  def self.exception(name, exception)
    error(name, type: exception.class.name, message: exception&.message)
  end

  ##
  # Tracks an error for error reporting with arbitrary additional named argument properties. Outputs `Error`
  #
  # @param [String] name A name for filtering within WHERE queries
  def self.error(name, **additional_properties)
    properties = { error_name: name }.merge(additional_properties)
    ::NewRelic::Agent.record_custom_event('Error', properties)
  rescue StandardError => e
    LOGGER.error("Failed reporting error to NewRelic: #{e}")
  end
end
