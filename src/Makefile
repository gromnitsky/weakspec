CS := coffee

out := ../lib
coffee := $(wildcard *.coffee)
js := $(patsubst %.coffee,$(out)/%.js,$(coffee))
browser := ../options.lib.js

.PHONY: compile browser clean

all: compile

$(out)/%.js: %.coffee
	$(CS) -cp $< > $@

browser: $(browser)

$(browser): $(coffee)
	$(CS) -jcp $^ > $@

compile: $(out) $(js)

clean:
	rm -rf $(js) $(browser)

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
