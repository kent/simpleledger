# CloudKit Workflow

Munnies uses `NSPersistentCloudKitContainer` with the iCloud container `iCloud.com.ewakened.munnies`.

The important operational detail is that TestFlight and App Store builds use the CloudKit production environment. If production does not have the current Core Data schema, sync and sharing fail with errors like `Cannot create new type CD_Kid in production schema`.

## Best Practices

- Treat CloudKit schema deployment as release infrastructure, not a one-off debug task.
- After any change to a syncable Core Data entity or attribute, update CloudKit production before sending the build to TestFlight.
- Use the repo script instead of ad hoc `cktool` or Ruby snippets.
- Keep exported schema files in `cloudkit/schema/` so the changes are reviewable.
- For production promotion, use CloudKit Console's `Deploy Schema Changes...` action after the development schema exists.

## Setup

1. Create or retrieve a CloudKit management token in CloudKit Console.
2. Save it once with `./scripts/cloudkit-munnies save-token` or export it as `CLOUDKIT_MANAGEMENT_TOKEN`.
3. Run `./scripts/cloudkit-munnies doctor`.

Apple reference:
- TestFlight and App Store use production CloudKit: https://developer.apple.com/help/cloudkit-dashboard/test-an-app-with-cloudkit
- CloudKit tokens and environment setup: https://developer.apple.com/documentation/cloudkit/setting-up-web-services-with-cloudkit

## Common Commands

- `./scripts/cloudkit-munnies doctor`
- `./scripts/cloudkit-munnies export development`
- CloudKit Console -> `Deploy Schema Changes...`

## Release Checklist

1. Run a current development build after Core Data model changes so development CloudKit reflects the new model.
2. Export the development schema into `cloudkit/schema/development.ckschema`.
3. Open CloudKit Console for `iCloud.com.ewakened.munnies` and click `Deploy Schema Changes...`.
4. Re-test sync and sharing from TestFlight.

## Current Sharing Failure

The TestFlight sharing error reported on March 6, 2026 is the expected failure mode when production is missing the Core Data-backed CloudKit record types. It will not fix itself on App Store release, because production is the environment already used by TestFlight.

## Current State

As of March 6, 2026, the development schema includes `CD_AppSettings`, `CD_Kid`, and `CD_Transaction`. Production still only shows the default `Users` record type, so the remaining step is the CloudKit Console deployment click.
