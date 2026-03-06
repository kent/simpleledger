# Web CI/CD

The repo now deploys the landing page to Cloud Run automatically when `main` receives changes under `web/`.

## Trigger

- branch: `main`
- paths:
  - `web/**`
  - `scripts/deploy-web-munnies`
  - `.github/workflows/deploy-web.yml`

## Deploy target

- project: `munnies-489414`
- region: `us-central1`
- Cloud Run service: `munnies-web`
- CDN URL map: `munnies-web-map`

## Authentication

GitHub Actions uses Google Workload Identity Federation, not a stored service account key.

Configured in GCP:

- workload identity pool: `github-actions`
- provider: `projects/362335167892/locations/global/workloadIdentityPools/github-actions/providers/github`
- service account: `munnies-web-deployer@munnies-489414.iam.gserviceaccount.com`
- provider condition: only tokens from `kent/simpleledger` on `refs/heads/main`

## Local deploy

```bash
./scripts/deploy-web-munnies
```

That deploy script also triggers a CDN cache invalidation on `munnies-web-map` so HTML changes become visible quickly after each release.

Optional overrides:

```bash
SERVICE_NAME=munnies-web GCP_PROJECT=munnies-489414 GCP_REGION=us-central1 ./scripts/deploy-web-munnies
```
