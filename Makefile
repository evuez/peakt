TARGETS=.targets
WEB=docker-compose run web

# Interface

## Setup
.PHONY: build
build: $(TARGETS)/build

.PHONY: deps
deps: $(TARGETS)/deps

## App lifecycle
.PHONY: _start start
_start:
	docker-compose up
start: | build deps _start

.PHONY: restart
restart:
	docker-compose restart

.PHONY: stop
stop:
	docker-compose stop


## Misc
.PHONY: console
console:
	$(WEB) iex -S mix

.PHONY: routes
routes:
	$(WEB) mix phoenix.routes

.PHONY: test
test:
	$(WEB) mix test

# Tasks

## Build
$(TARGETS)/build: mix.exs mix.lock Dockerfile
	docker-compose build
	touch $@

$(TARGETS)/deps: mix.exs mix.lock package.json
	$(WEB) mix deps.clean --unused --unlock
	$(WEB) mix do deps.get, deps.compile
	$(WEB) npm install
	touch $@
