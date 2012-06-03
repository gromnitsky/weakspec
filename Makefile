CS := coffee
MOCHA := node_modules/.bin/mocha

src := $(wildcard *.coffee)
js := $(patsubst %.coffee,%.js,$(src))

.PHONY: clean clobber compile test browser

all: test

node_modules: package.json
	npm install
	touch $@

clobber: clean
	rm -rf node_modules

%.js: %.coffee
	$(CS) -cp $< > $@

browser:
	$(MAKE) -C src $@

clean:
	rm -rf $(js)
	$(MAKE) -C src clean

lib:
	mkdir -p $@

compile: node_modules lib $(js) browser
	$(MAKE) -C src compile

test: compile
	$(MOCHA) --compilers coffee:coffee-script -u tdd

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
