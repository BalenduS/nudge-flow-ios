# Admin Portal Implementation Plan

## Priority

The admin portal becomes production-ready once the Supabase project is live. The static portal in `AdminPortal/` is the UI and workflow scaffold; `supabase/migrations/001_admin_foundation.sql` and `supabase/migrations/002_auth_sync_bootstrap.sql` are the backend starting point.

## Backend Stack

- Supabase Auth for account identity.
- Postgres for app data.
- Row-Level Security on all user-owned tables.
- `admin_memberships` for internal roles.
- `admin_audit_log` for support/admin access records.

## Admin Roles

- `owner`: full access, role management, billing configuration.
- `admin`: users, notifications, subscriptions, product operations.
- `support`: support-gated user detail access.
- `content_editor`: Learn CMS only.

## Production Gates

1. Create the Supabase project and run both migrations.
2. Add Supabase URL and anon key to `NudgeFlow/Config/SupabaseConfig.swift`.
3. Test iOS email/password account creation from Profile.
4. Persist fasting sessions, weight, mood, and water summaries to Supabase.
5. Replace portal seed data with Supabase queries.
6. Add admin login.
7. Gate sensitive user-detail views behind support reason.
8. Write every sensitive admin action to `admin_audit_log`.
9. Add export/delete request fulfillment workflows.

## Privacy Rules

- Default dashboard metrics should be aggregate.
- User-level fasting, mood, and consumption logs require support reason.
- Export/delete requests need explicit status transitions.
- Raw exports should be short-lived files, not permanent public URLs.
