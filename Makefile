.phony: build run

NAMESPACE := iam
NAME := keycloak
VERSION := 6.0.1

TAG := $(NAMESPACE)/$(NAME):$(VERSION)

build:
	@docker build -t $(TAG) .

run: build
	@docker run --name $(NAME) --rm -it -p 8080:8080 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin $(TAG)
