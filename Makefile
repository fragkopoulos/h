SHELL := bash
PATH := bin:${PATH}

clean:
	find h/js -iname '*.js' | xargs rm
	find h/css -iname '*.css' | xargs rm

test: elasticsearch functional_test unit_test

functional_test: 
ifneq ($(TRAVIS_SECURE_ENV_VARS),false)
	@echo "running functional tests"

	# stop the test daemon if it is running
	hypothesis serve --stop-daemon

	# start with clean test db
	rm -f test.db

	# ensure the assets are built
	hypothesis assets test.ini

	# start the test instance of h
	hypothesis serve --daemon test.ini

	# run the functional tests
	py.test tests/functional/

	# stop h
	hypothesis serve --stop-daemon
endif

unit_test: 
	@echo "running unit tests"

	rm -f test.db
	py.test tests/unit

elasticsearch:
	@echo "elasticsearch running?"
	$(eval es := $(shell wget --quiet --output-document - http://localhost:9200))
	@if [ -n '${es}' ] ; then echo "elasticsearch running" ; else echo "please start elasticsearch"; exit 1; fi
