setup:
	@docker build . \
		--progress plain \
		-f Containerfile \
		-t fedora-base

run:
	@docker run \
		--name fedora-base \
		--rm \
		-i \
		-t \
		fedora-base

test:
	@$(CURDIR)/tests/index.sh
