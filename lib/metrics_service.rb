class MetricsService
  def self.event(name, **additional_properties)
    properties = {name: name}.merge(additional_properties)
    ::NewRelic::Agent.record_custom_event("TrackedEvent", properties)
  end

  def self.time_operation(name, **additional_properties)
    raise 'A block is required for time_operation calls' unless block_given?

    start = Time.current
    yield
    duration_start_end(name, start, Time.current, **additional_properties)
  rescue StandardError => e
    Rails.logger.error("Failed reporting timing to NewRelic: #{e}")
  end

  def self.duration_start_end(name, start, finish, **additional_properties)
    duration(name, (finish - start).seconds, **additional_properties)
  rescue StandardError => e
    Rails.logger.error("Failed reporting duration to NewRelic: #{e}")
  end

  def self.duration(name, duration, **additional_properties)
    properties = {name: name, duration: duration.in_milliseconds}.merge(additional_properties)
    ::NewRelic::Agent.record_custom_event("OpDurationMs", properties)
  rescue StandardError => e
    Rails.logger.error("Failed reporting duration to NewRelic: #{e}")
  end

  def self.exception(name, exception)
    error(name, type: exception.class.name, message: exception&.message)
  end

  def self.error(name, **additional_properties)
    properties = {error_name: name}.merge(additional_properties)
    ::NewRelic::Agent.record_custom_event("Error", properties)
  rescue StandardError => e
    Rails.logger.error("Failed reporting error to NewRelic: #{e}")
  end
end
