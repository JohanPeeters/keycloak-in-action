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
* However, the downside of using OIDC is that it is impossible to pass claims via the ADFS userinfo endpoint to Keycloak to create local Keycloak users. This is due to https://docs.microsoft.com/en-us/windows-server/identity/ad-fs/overview/ad-fs-faq#i-am-trying-to-get-additional-claims-on-the-user-info-endpoint-but-its-only-returning-subject-how-can-i-get-additional-claims => Keycloak queries the ADFS userinfo endpoint for additional claims, but ADFS only returns the sub claim. Note that this issue is not due to missing scopes. Even if the correct scopes are added using `Grant-AdfsApplicationPermission -ClientRoleIdentifier keycloak -ServerRoleIdentifier urn:microsoft:userinfo -ScopeNames openid,email`. It really is a 'feature' of ADFS.
* The above issue can be resolved by create a 'dummy API' in ADFS, linking it to the Keycloak client, and then adding extra claims to the access token. 
    * I assume keycloak is created as a confidential server application in an Application Group
    * Add a dummy API to that application group, make sure the 'relying party identifier' exactly matches the clientId of the server application
    * Make sure to check 'allatclaims' in the client permissions tab. This is required since Keycloak maps from the id_token, not from the access_token
    * Create a new transform rule which sends the following LDAP attributes: E-Mail-Addresses, Given_name, Surname
    * Apply
* For this solution to work, you must tell Keycloak NOT to call the userinfo endpoint (since the access token issued by ADFS will only be valid for the 'dummy API', not for the userinfo endpoint. The userinfo endpoint does not contain much info anyway, see above)
* Then, in Keycloak, you must map the attributes from the ADFS token to attributes Keycloak understands:
    * email to email
    * family_name to lastName
    * given_name to firstName
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
* https://docs.microsoft.com/en-us/windows-server/identity/ad-fs/development/custom-id-tokens-in-ad-fs
