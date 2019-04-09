default:
	echo "Available commands: test; build; version=X.X.X push"

test:
	rspec

build: test
	gem build opinionated-metrics.gemspec

push:
	gem push opinionated-metrics-$(version).gem
