DAZN Bet SSO is essentially an **OAuth2/OIDC authorization-code flow**, with DAZN acting as the identity provider and DAZN Bet creating its own local session.

### Backend flow

1. **Register DAZN Bet as an OAuth client**
   - DAZN Auth holds the DAZN Bet client configuration: client ID, allowed redirect URI(s), audience and scopes.
   - The DAZN Bet backend securely stores its client secret. Never expose it to the app/browser.

2. **Start the SSO journey**
   - DAZN Bet’s frontend asks its backend for an authorization URL, or DAZN Hub initiates the authorised redirect.
   - The request includes `client_id`, `redirect_uri`, requested scopes and a CSRF `state` value.

3. **DAZN authenticates the customer**
   - DAZN Auth reuses the customer’s existing DAZN sign-in/session where available.
   - After authentication, DAZN Auth returns the browser/app to the DAZN Bet redirect URI with a short-lived, one-time **authorization code**.

4. **DAZN Bet backend receives the code**
   - The frontend passes the code and original `state` to DAZN Bet backend.
   - Validate `state` before proceeding to prevent login-CSRF or redirect attacks.

5. **Exchange code server-to-server**
   - DAZN Bet backend calls DAZN Auth’s token endpoint with:
     - authorization code
     - DAZN Bet client ID
     - client secret
     - relevant device/IP context where required
   - DAZN Auth responds with an **ID token** and, where configured, access/refresh tokens.

6. **Validate the ID token**
   - DAZN Bet backend fetches DAZN’s OIDC discovery document and JWKS public keys.
   - Validate the JWT signature and key ID, plus:
     - issuer (`iss`)
     - audience (`aud`)
     - expiry / issued-at (`exp`, `iat`)
     - token type / nonce if used
   - Do not trust claims until validation succeeds.

7. **Find or create the DAZN Bet customer link**
   - Use DAZN’s stable customer identifier (`sub` / provider customer ID) as the primary linkage key.
   - Check whether that DAZN identity is already linked to a DAZN Bet account.
   - If not, create a pending/partial Bet profile and complete any mandatory betting onboarding: age, jurisdiction, KYC, responsible-gambling and regulatory checks.
   - Email can assist matching, but should not be the sole identity key.

8. **Issue a DAZN Bet session**
   - DAZN Bet backend creates its **own** session/access token for its frontend.
   - The DAZN frontend should not use DAZN-issued tokens directly to call DAZN Bet APIs.

9. **Refresh and delink**
   - If refresh tokens are enabled, refresh them only from DAZN Bet backend.
   - On account delink, revoke the DAZN refresh token through the DAZN Auth revocation endpoint and delete/disable the identity mapping according to retention and regulatory requirements.

### In one line

`DAZN login → one-time code → DAZN Bet backend exchanges and validates it → link/create Bet user → issue DAZN Bet session.`

### Important backend safeguards

- Authorization codes are short-lived and single-use.
- Client secrets and refresh tokens stay server-side, encrypted at rest.
- Strictly allow-list redirect URIs.
- Validate `state`, JWT signature, issuer, audience and expiry.
- Log authentication outcomes without logging tokens or sensitive customer data.
- Treat successful DAZN identity SSO separately from **DAZN Bet eligibility and regulated onboarding**.

This reflects the established SSO design; the most recent related Jira item found confirms the DAZN Bet redirect is triggered through the authorize flow, while the detailed architecture documentation is older.