CS := coffee
MOCHA := node_modules/.bin/mocha

src := $(wildcard *.coffee)
js := $(patsubst %.coffee,%.js,$(src))

.PHONY: clean clobber compile test

all: test

node_modules: package.json
	npm install
	touch $@

clobber: clean
	rm -rf node_modules

%.js: %.coffee
	$(CS) -cp $< > $@

clean:
	rm -rf lib $(js)

lib:
	mkdir -p $@

compile: node_modules lib $(js)
	$(MAKE) -C src

test: compile
	$(MOCHA) --compilers coffee:coffee-script -u tdd

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
