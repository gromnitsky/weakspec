CS := coffee
MOCHA := node_modules/.bin/mocha

src := $(wildcard src/*.coffee)
js := $(patsubst src/%.coffee,lib/%.js,$(src))

.PHONY: clean clobber compile test

all: test

node_modules: package.json
	npm install
	touch $@

clobber: clean
	rm -rf node_modules

lib/%.js: src/%.coffee
	$(CS) -cp $< > $@

clean:
	rm -rf lib

lib:
	mkdir -p $@

compile: node_modules lib $(js)

test: compile
	$(MOCHA) --compilers coffee:coffee-script -u tdd

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
