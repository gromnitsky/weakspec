CS := coffee

out := ../spec
coffee := $(wildcard *.coffee)
js := $(patsubst %.coffee,$(out)/%.js,$(coffee))

.PHONY: compile clean

all: compile

$(out)/%.js: %.coffee
	$(CS) -cp $< > $@

$(out):
	mkdir -p $@

compile: $(out) $(js)

clean:
	rm -rf $(out)

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
