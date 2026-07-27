# Portfolio "Add Me" → Grafana Viewer Feature

## Overview

Visitors on the portfolio project section enter their email and get temporary
read-only access to Grafana at grafana.gbklabs.com. Cloudflare Access handles
authentication; Grafana trusts whoever Cloudflare lets through.

---

## Architecture

```
Portfolio site
  └── "Add me" form (email input)
        │
        ▼
  api.gbklabs.com/invite  (small API running in k3s)
        │
        ├── 1. Rate limit check (per IP)
        ├── 2. Add email to Cloudflare Access policy via CF API
        └── 3. Send welcome email via Gmail SMTP (App Password)

Visitor receives email → visits grafana.gbklabs.com
  └── Cloudflare Access login page
        ├── "Sign in with Google" (existing)
        └── "Send me a code" OTP  ← NEW, works with ANY email
              │
              ▼
        Grafana (trusts CF-Access-Authenticated-User-Email header)
              └── Auto-provisions user as Viewer role
```

---

## Key Decisions

### Identity Provider: Add OTP alongside Google
- Cloudflare Access → Settings → Authentication → Add "One-time PIN"
- One-click enable, no extra configuration
- Works with Gmail, Outlook, corporate email — anything
- Users see two options on the login page: Google button OR "Send me a code"
- The Access *policy* checks email address regardless of which IdP was used

### Skip Grafana user management entirely
- Configure Grafana to read the `CF-Access-Authenticated-User-Email` header
- Grafana auto-provisions any email that Cloudflare lets through as a Viewer
- No Grafana API calls needed from the invite API
- No Grafana invite emails, no password management
- Revoke access = remove email from Cloudflare Access policy

### Email delivery: Gmail SMTP with App Password
- Google Account → Security → 2-Step Verification → App Passwords → generate
- SMTP: `smtp.gmail.com:587` (STARTTLS), user: `gilbertbatista.k@gmail.com`
- App password stored as a k8s Secret, never in git
- Revocable independently of the Gmail account password
- 500 emails/day limit — more than enough for a portfolio

### Access cleanup: time-limited entries
- Cloudflare Access policies support expiry dates on email rules via the API
- Set each added email to expire after 7 days automatically
- No cron job needed — Cloudflare handles it

---

## Spam / Abuse Protection

- Rate limit: 1 invite per IP per hour (in-memory or Redis)
- Optional: hCaptcha (free, Cloudflare-native) on the form
- Cloudflare Access itself limits the blast radius — a bad actor can only
  create viewer-only Grafana sessions, nothing writable

---

## Components to Build

### 1. Invite API (k3s deployment)
- Language: Node.js (Fastify) or Python (FastAPI) — small, stateless
- Endpoints:
  - `POST /invite` — validate email, call CF API, send email
- Secrets needed (k8s Secrets, never in git):
  - `CF_API_TOKEN` — scoped to Access policy edit only
  - `CF_ACCOUNT_ID` and `CF_POLICY_ID`
  - `GMAIL_APP_PASSWORD`
- Exposed via Traefik IngressRoute at `api.gbklabs.com`
- Cloudflare Access policy on `api.gbklabs.com/invite`: **public** (no auth,
  it's the unauthenticated entry point)

### 2. Grafana config changes
```ini
# grafana.ini additions (via Helm values)
[auth.proxy]
enabled = true
header_name = CF-Access-Authenticated-User-Email
header_property = email
auto_sign_up = true
default_role = Viewer
```
Important: Grafana must only be reachable through Cloudflare (Traefik should
reject requests without the CF-Access-Jwt-Assertion header) so the proxy auth
can't be spoofed directly.

### 3. Cloudflare Access changes
- Enable OTP identity provider
- Add email rule that grants access when email is in the dynamic list
  (managed via CF API by the invite service)

### 4. Portfolio site changes
- Add email input + submit button to the project section
- POST to `https://api.gbklabs.com/invite`
- Show success/error state

---

## Homelab hosting + GitHub Pages failover (separate but related)

### Option chosen: Cloudflare Worker proxy
- Domain points to a Worker at the edge (no direct IP exposure)
- Worker fetches from homelab first; falls back to GitHub Pages on error/5xx
- No DNS TTL delay on failover — decision made at the edge per request
- Free tier: 100k requests/day

### Cloudflare Tunnel (prerequisite)
- Run `cloudflared` as a k3s pod
- Eliminates open ports on the router for the portfolio site
- Traffic: visitor → Cloudflare edge → tunnel → Traefik → portfolio pod

### GitHub Pages (fallback origin)
- Keep the repo configured for GitHub Pages on the `gh-pages` branch
- Worker falls back to `https://kakuhiry.github.io` (or custom domain CNAME)

### Worker logic (pseudocode)
```js
async function handleRequest(request) {
  try {
    const res = await fetch("https://homelab-origin.internal" + request.url, {
      signal: AbortSignal.timeout(3000)
    });
    if (res.ok || res.status < 500) return res;
    throw new Error("upstream error");
  } catch {
    return fetch("https://kakuhiry.github.io" + new URL(request.url).pathname);
  }
}
```

---

## Implementation Order
1. Cloudflare Tunnel for portfolio (security baseline)
2. Host portfolio on k3s + Worker failover
3. Enable OTP in Cloudflare Access
4. Grafana proxy auth header config
5. Invite API deployment
6. Portfolio "Add me" form
