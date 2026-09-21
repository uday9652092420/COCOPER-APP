# Release Checklist

## Product and backend

- Confirm role-to-feature matrix and branch access with the client.
- Confirm backend lookup IDs, transaction payloads and report envelopes.
- Verify ton/piece lessing limits and notification/approval rules server-side.
- Test invoice-wise and cumulative receipts/payments.
- Test Cash, Bank and UPI handling and P&L reconciliation.
- Disable `USE_MOCK_BACKEND` in staging/production.

## Security and operations

- Configure production HTTPS API base URL.
- Complete threat review and API authorization tests.
- Add certificate pinning only with an approved certificate rotation policy.
- Configure crash reporting and monitoring without request/response payloads.
- Verify privacy policy, retention and support contacts.
- Provide Android keystore and Apple signing profiles outside source control.
- Rotate any credentials used during QA.

## Quality

- Run formatter, analyzer and all tests.
- Run API contract and offline/reconnect tests against staging.
- Test phones, 7–8 inch tablets and 10–13 inch tablets.
- Test English, Hindi, Telugu, Tamil and Kannada on every route.
- Test text scaling, landscape tablet layout and low-memory restart.
- Test a queued transaction cannot be duplicated after retry.
- Confirm report exports open through a signed HTTPS URL.

## Store delivery

- Finalize package/bundle identifiers and version/build numbers.
- Verify COCOPER app icons, display name and launch artwork.
- Generate obfuscated release artifacts and retain matching debug symbols.
- Sign and upload through the client's Play Console/App Store Connect accounts.
- Perform staged rollout with monitoring and rollback ownership agreed.
