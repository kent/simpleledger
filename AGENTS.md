# AGENTS.md

## Project defaults
- App bundle ID: `com.ewakened.munnies`
- Apple Developer Team ID: `PS5W7BFTQ2`
- App Store Connect Team ID: `150077`
- App Store Connect Team Name: `Kent Fenwick`
- App Store Connect Issuer ID: `69a6de6e-8f71-47e3-e053-5b8c7c11a4d1`
- Preferred local API key ID: `2XG664G4GG`
- Local App Store config file: `fastlane/.env.local`

## Required App Store workflow for agents
- Do not use ad hoc `ruby <<'RUBY'` / raw `spaceship` commands for normal release work when the repo scripts already cover it.
- Use [`scripts/appstore-munnies`](/Users/kent/bliss/munnies/scripts/appstore-munnies) for App Store Connect and TestFlight operations.
- One-time local setup:
  - `./scripts/appstore-munnies setup-local`
  - `./scripts/appstore-munnies doctor`
- Common commands:
  - `./scripts/appstore-munnies config`
  - `./scripts/appstore-munnies status`
  - `./scripts/appstore-munnies release`
  - `./scripts/appstore-munnies testflight`
  - `./scripts/appstore-munnies metadata`
  - `./scripts/appstore-munnies screenshots`
  - `./scripts/appstore-munnies price price_tier:2`
- `fastlane/.env.local` is local-only and must never be committed.

## CloudKit workflow
- Use [`scripts/cloudkit-munnies`](/Users/kent/bliss/munnies/scripts/cloudkit-munnies) for schema export/import and token handling.
- Do not hand-roll `cktool` commands if the repo script already covers the task.

## GCP / website defaults
- GCP project: `munnies-489414`
- Region: `us-central1`
- Cloud Run service: `munnies-web`
- Deployment service account: `munnies-web-deployer@munnies-489414.iam.gserviceaccount.com`
- gcloud config name: `munnies-deployer`

## Required GCP workflow for agents
- Use [`scripts/gcloud-munnies`](/Users/kent/bliss/munnies/scripts/gcloud-munnies) for `gcloud` commands in this repo.
- Use [`scripts/deploy-web-munnies`](/Users/kent/bliss/munnies/scripts/deploy-web-munnies) for manual web deploys.
- Do not switch to a personal `gcloud` config for Munnies operations.
