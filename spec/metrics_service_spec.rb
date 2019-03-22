# frozen_string_literal: true

require 'metrics_service'

RSpec.describe MetricsService do
  it 'should be defined' do
    expect(MetricsService).not_to be_nil
  end

  describe '#exception' do
    it 'should accept additional_properties' do
      expect(::NewRelic::Agent).to receive(:record_custom_event).with('Error', hash_including(type: 'StandardError', mykey: 'myvalue'))
      MetricsService.exception('foo', StandardError.new('excmsg'), mykey: 'myvalue')
    end
  end
end
