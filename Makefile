setup:
	@docker build --progress=plain -f Containerfile -t fedora-base .

shell:
	@docker run --rm -it --name="fedora-base" \
		fedora-base

test:
	@$(CURDIR)/tests/index.sh
