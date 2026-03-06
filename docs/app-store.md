# App Store Workflow

This repo now owns the App Store workflow. The goal is to stop using one-off `ruby <<'RUBY'` commands and keep the release path predictable, reviewable, and version controlled.

## Best Practices

- Use the pinned `Gemfile` and run fastlane through `bundle exec`.
- Prefer App Store Connect API keys over interactive Apple ID sessions.
- Keep metadata and screenshots in git.
- Add new App Store Connect automation as named lanes or scripts, not shell heredocs.

## One-Time Local Setup

Run:

```sh
./scripts/appstore-munnies setup-local
./scripts/appstore-munnies doctor
```

`setup-local` writes `fastlane/.env.local` with the known Munnies defaults:

- `FASTLANE_USER=kent.fenwick@gmail.com`
- `FASTLANE_TEAM_ID=PS5W7BFTQ2`
- `FASTLANE_ITC_TEAM_ID=150077`
- `FASTLANE_ITC_TEAM_NAME=Kent Fenwick`
- `ASC_KEY_ID=2XG664G4GG`
- `ASC_ISSUER_ID=69a6de6e-8f71-47e3-e053-5b8c7c11a4d1`

It also tries to detect the `.p8` file automatically from standard local locations like:

- `$HOME/.keys/AuthKey_<KEY_ID>.p8`
- `$HOME/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8`

If the key file is not found automatically, edit `fastlane/.env.local` and set `ASC_KEY_FILE` manually.

`fastlane/.env.local` is for local machine config and is ignored by git.

If no API key is configured, the lanes still work with Apple ID auth, but that is the fallback path, not the preferred one.

## Common Commands

- `./scripts/appstore-munnies config`
- `./scripts/appstore-munnies status`
- `./scripts/appstore-munnies build`
- `./scripts/appstore-munnies release`
- `./scripts/appstore-munnies testflight`
- `./scripts/appstore-munnies beta`
- `./scripts/appstore-munnies prepare-beta groups:"Internal Testers"`
- `./scripts/appstore-munnies metadata`
- `./scripts/appstore-munnies screenshots`
- `./scripts/appstore-munnies price price_tier:2`
- `./scripts/appstore-munnies download-metadata`

## Daily Flow

Most of the time you only need:

```sh
./scripts/appstore-munnies release
```

That uses the local defaults from `fastlane/.env.local`, builds the app, uploads build metadata, uploads the IPA to TestFlight, waits for the build to appear, and sets the changelog.

## Scope

`fastlane/Fastfile` covers the common, supported operations:

- local toolchain validation
- signed App Store builds
- TestFlight uploads
- store metadata and screenshot uploads
- price tier updates
- a read-only App Store Connect status snapshot

If you need a new App Store Connect mutation later, add it here as a named lane instead of pasting another ad hoc Ruby snippet into the shell.
