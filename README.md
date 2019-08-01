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

# Lessons learned
* When using ADFS as an Identity Provider, one can choose between a SAML integration or an OIDC integration. Both work, but the OIDC integration is a bit easier since the discovery document can be used to establish trust. In SAML, an exchange of certificates is a mandatory prerequisite.
* However, the downside of using OIDC is that it is impossible to pass claims from ADFS to Keycloak to create local Keycloak users. This is due to https://docs.microsoft.com/en-us/windows-server/identity/ad-fs/overview/ad-fs-faq#i-am-trying-to-get-additional-claims-on-the-user-info-endpoint-but-its-only-returning-subject-how-can-i-get-additional-claims => Keycloak queries the ADFS userinfo endpoint for additional claims, but ADFS only returns the sub claim. 
* Note that this issue is not due to missing scopes. I have added the correct scopes for the userinfo endpoint using `Grant-AdfsApplicationPermission -ClientRoleIdentifier keycloak -ServerRoleIdentifier urn:microsoft:userinfo -ScopeNames openid,email`. It really is a 'feature' of ADFS.
* The above issue can usually be resolved by create a 'dummy API' in ADFS, linking it to the Keycloak client, and then adding extra claims to the access token. However, Keycloak does not expect the claims to be present in the access token, instead it expects them to be present at the userinfo endpoint.  
* Do not use white spaces in the realm names. This will give encoding problems. 
* When using SAML, the nameidentifier must have the same format as expected by the Identity Provider (e.g. persistent)
* Troubleshooting:
    * use https://www.samltool.com/decode.php to decode SAML tokens
    * use Keycloak's output console
    * (ADFS only) use the Windows Event Viewer
    * (ADFS only) increase the logging level: `Set-AdfsProperties -AuditLevel Verbose` 


# Under the hood

The magic happens in `realm.json`, where the configuration changes reside.

# Disclaimers

Vanilla Keycloak comes with a single realm, Master. This is dedicated to users with administrative privileges. So an additional realm for end-users has been created which is imported by the command line executed by the `run` make target. In a production scenario, a realm would obviously be stored persistently in a database.

The configuration for a demo is currently hard-coded. This is not a good practice.

The Dockerfile does not really do anything currently - it merely specifies the version of a Keycloak Docker base image. This could have been done on the command line as well. Consider it a placeholder for further layers.

A self-signed certificate is used for KeyCloak, so your browser will not like that.

# References
* https://www.keycloak.org/2017/03/how-to-setup-ms-ad-fs-30-as-brokered-identity-provider-in-keycloak.html
