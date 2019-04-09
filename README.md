Simple metrics helper built to be agnostic of particular backends.

Examples
========

##### Record simple event:

```
MetricsService.event('MessageHandledSuccess')
```

##### Record timings of operations:

This example will push three metrics - one for the overall processing time, and one per step

```
def complex_method
  start = Time.current
  MetricsService.time_operation('complex_method_overall') do
    puts 'Step 1...'
    sleep 10
    MetricsService.duration_start_end('step_1', start, Time.current)
    after_step_1 = Time.current
    puts 'Step 2...'
    sleep 30
    MetricsService.duration_start_end('step_2', after_step_1, Time.current)
  end
end
```

##### Record an exception:

```
rescue StandardError => e
  MetricsService.exception('suppressable_path', e)
end
```

Usage in development
====================

Pushing events to NewRelic can be tricky because they try to avoid sending useless telemetry to their servers. Try reading through the tips in https://discuss.newrelic.com/t/just-get-nil-when-trying-to-use-ruby-agent-to-record-custom-event-for-new-relic-insights/27442/2 , especially using NEW_RELIC_AGENT_ENABLED=true for your consoles, while testing.
