CS := coffee

lib := ../lib
src := $(wildcard *.coffee)
js := $(patsubst %.coffee,$(lib)/%.js,$(src))

.PHONY: compile

all: compile

$(lib)/%.js: %.coffee
	$(CS) -cp $< > $@

$(lib):
	mkdir -p $@

compile: $(lib) $(js)

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
