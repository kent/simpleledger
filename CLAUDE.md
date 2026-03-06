# CLAUDE.md

Use these defaults for Munnies operational work:

- Bundle ID: `com.ewakened.munnies`
- Apple Developer Team ID: `PS5W7BFTQ2`
- App Store Connect Team ID: `150077`
- App Store Connect Team Name: `Kent Fenwick`
- App Store Connect Issuer ID: `69a6de6e-8f71-47e3-e053-5b8c7c11a4d1`
- Preferred local API key ID: `2XG664G4GG`
- Local App Store config file: `fastlane/.env.local`

App Store guardrails:

- Use `./scripts/appstore-munnies setup-local` once on a fresh machine or fresh repo checkout.
- Validate with `./scripts/appstore-munnies doctor`.
- Use `./scripts/appstore-munnies release` for the normal build-and-upload TestFlight flow.
- Use `./scripts/appstore-munnies testflight` for upload-only and `./scripts/appstore-munnies status` to inspect ASC state.
- Prefer the repo-owned fastlane lanes and wrapper script over one-off Ruby or `spaceship` shell snippets.
- Never commit `fastlane/.env.local`.

CloudKit guardrails:

- Use `./scripts/cloudkit-munnies` for CloudKit schema and token work.

GCP / website defaults:

- Project: `munnies-489414`
- Region: `us-central1`
- Cloud Run service: `munnies-web`
- Deployment service account: `munnies-web-deployer@munnies-489414.iam.gserviceaccount.com`
- gcloud config name: `munnies-deployer`

GCP guardrails:

- Use `./scripts/gcloud-munnies ...` for repo `gcloud` commands.
- Use `./scripts/deploy-web-munnies` for manual web deploys.
- Do not use a personal `gcloud` profile for Munnies changes.
