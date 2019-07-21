.phony: build run

NAMESPACE := iam
NAME := keycloak
VERSION := 6.0.1

TAG := $(NAMESPACE)/$(NAME):$(VERSION)

build:
	@docker build -t $(TAG) .

run: build
	@docker run --name $(NAME) --rm -it -p 8080:8080 -p 8443:8443 \
	 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin \
	 -e KEYCLOAK_IMPORT=/tmp/realm.json \
	 -v $(shell pwd):/tmp \
	 $(TAG)

reload:
	@docker exec keycloak /opt/jboss/keycloak/bin/jboss-cli.sh --connect reload
