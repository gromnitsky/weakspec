CS := coffee

lib := ../lib
coffee := $(wildcard *.coffee)
js := $(patsubst %.coffee,$(lib)/%.js,$(coffee))
browser := ../options.lib.js

.PHONY: compile browser clean

all: compile

$(lib)/%.js: %.coffee
	$(CS) -cp $< > $@

$(lib):
	mkdir -p $@

browser: $(browser)

$(browser): $(coffee)
	$(CS) -jcp $^ > $@

compile: $(lib) $(js)

clean:
	rm -rf $(lib) $(browser)

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
