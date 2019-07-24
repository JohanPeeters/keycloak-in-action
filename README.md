This repo offers a very thin layer over a vanilla Keycloak Docker image to demonstrate interacting with ADFS as a brokered identity provider.

# Prerequisites

* docker installed and running
* make installed
* git installed

# Usage

```
git clone git@github.com:JohanPeeters/keycloak-in-action.git
cd keycloak-in-action
make run
```

The shell in which `make run` executes remains attached to the Keycloak server stdout and stdin, so you see it starting up and throwing exceptions.

When the server has started up, its UI is available at `https://localhost:8443`. You can log into the management console with `admin:admin`.

A single client has been configured with identifier `spa`. This client can start an OIDC authorization code flow with the running Keycloak instance as the authorization server.

Keycloak has been configured to act as a broker for several Identity Providers. For this to work, the `client_secret` for these IdPs needs to be configured - these are not in the configuration.

#Under the hood

The magic happens in `realm.json`, where the configuration changes reside.

# Disclaimers

Vanilla Keycloak comes with a single realm, Master. This is dedicated to users with administrative privileges. So an additional realm for end-users has been created which is imported by the command line executed by the `run` make target. In a production scenario, a realm would obviously be stored persistently in a database.

The configuration for a demo is currently hard-coded. This is not a good practice.

The Dockerfile does not really do anything currently - it merely specifies the version of a Keycloak Docker base image. This could have been done on the command line as well. Consider it a placeholder for further layers.

A self-signed certificate is used for KeyCloak, so your browser will not like that.
