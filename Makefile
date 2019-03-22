test:
	rspec

build: test
	gem build opinionated-metrics.gemspec

push:
	gem push opinionated-metrics-$(version).gem
