# This Makefile assumes you have a local install of bikeshed. Like any
# other Python tool, you install it with pip:
#
#     pipx install bikeshed && bikeshed update

SHELL=/bin/bash -o pipefail
.PHONY: all publish clean remote
.SUFFIXES: .bs .html

all: publish

clean:
	rm -rf index.html *~

publish: index.html

index.html: index.bs Makefile
	bikeshed --die-on=warning spec $< $@

# Build the spec using a remote version of bikeshed.
#
# Note that the remote bikeshed tool does not support uploading images and will
# give a warning. Hence it will fail unless the warnings are allowed.
remote: index.bs
	@ (HTTP_STATUS=$$(curl https://api.csswg.org/bikeshed/ \
	                       --output index.html \
	                       --write-out "%{http_code}" \
	                       --header "Accept: text/plain, text/html" \
	                       -F die-on=fatal \
	                       -F file=@index.bs) && \
	[[ "$$HTTP_STATUS" -eq "200" ]]) || ( \
		echo ""; cat index.html; echo ""; \
		rm -f index.html; \
		exit 22 \
	);
