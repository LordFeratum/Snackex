build:
	docker build -t snackex .

run:
	docker run --rm --env-file .env
