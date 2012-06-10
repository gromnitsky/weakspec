CS := coffee
MOCHA := node_modules/.bin/mocha
M4 := gm4

coffee := $(wildcard *.coffee)
js := $(patsubst %.coffee,%.js,$(coffee))

.PHONY: clean clobber compile test browser jasmine

all: test

jasmine:
	$(MAKE) -C test/spec-coffee

test: compile jasmine
	$(MOCHA) --compilers coffee:coffee-script -u tdd

compile: node_modules
	$(MAKE) -C src compile

options.html: options.m4 style.css compile browser
	$(M4) $< > $@

node_modules: package.json
	npm install
	touch $@

clobber: clean
	rm -rf node_modules

clean:
	rm -rf $(js) options.html
	$(MAKE) -C src clean
	$(MAKE) -C test/spec-coffee clean

%.js: %.coffee
	$(CS) -cp $< > $@

browser: $(js)
	$(MAKE) -C src $@

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
