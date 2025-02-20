# This Makefile assumes you have a local install of bikeshed. Like any
# other Python tool, you install it with pip:
#
#     python3 -m pip install bikeshed && bikeshed update

# It also assumes you have doctoc installed. This is a tool that
# automatically generates Table of Contents for Markdown files. It can
# be installed like any other NPM module:
#
#    npm install -g doctoc

SHELL=/bin/bash -o pipefail
.PHONY: all publish clean update-explainer-toc remote
.SUFFIXES: .bs .html

all: publish update-explainer-toc

clean:
	rm -rf index.html *~

publish: index.html

update-explainer-toc: README.md Makefile
	doctoc $< --title "## Table of Contents" > /dev/null

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
