ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

build:
	@docker build -t snackex .

run:
	@docker run --rm --env-file .env

build-dev:
	@docker build -f Dockerfile.dev -t snackex_dev --rm .

run-dev:
	@docker run --rm --env-file .env -it -v "$(ROOT_DIR)"/src:/app snackex_dev:latest
