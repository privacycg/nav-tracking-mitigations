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
	rm -rf build *~

publish: build/index.html

update-explainer-toc: README.md Makefile
	doctoc $< --title "## Table of Contents" > /dev/null

build/index.html: index.bs Makefile
	mkdir -p build
	bikeshed --die-on=warning spec $< $@

remote: index.bs
	mkdir -p build
	@ (HTTP_STATUS=$$(curl https://api.csswg.org/bikeshed/ \
	                       --output build/index.html \
	                       --write-out "%{http_code}" \
	                       --header "Accept: text/plain, text/html" \
	                       -F die-on=warning \
	                       -F md-Text-Macro="COMMIT-SHA LOCAL COPY" \
	                       -F file=@index.bs) && \
	[[ "$$HTTP_STATUS" -eq "200" ]]) || ( \
		echo ""; cat build/index.html; echo ""; \
		rm -f build/index.html; \
		exit 22 \
	);
