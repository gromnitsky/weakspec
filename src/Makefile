CS := coffee

lib := ../lib
src := $(wildcard *.coffee)
js := $(patsubst %.coffee,$(lib)/%.js,$(src))
browser := ../options.lib.js

.PHONY: compile browser clean

all: compile

$(lib)/%.js: %.coffee
	$(CS) -cp $< > $@

$(lib):
	mkdir -p $@

browser: $(browser)

$(browser): $(src)
	coffee -jcp $^ > $@

compile: $(lib) $(js) $(browser)

clean:
	rm -rf $(lib) $(browser)

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
