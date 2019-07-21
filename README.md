This repo offers a very thin layer over a vanilla Keycloak Docker image to demonstrate interacting with ADFS as a brokered identity provider.

Vanilla Keycloak comes with a single realm, Master. This is dedicated to users with administrative privileges. So an additional realm for end-users has been created which is imported by the command line executed by the `run` make target.
