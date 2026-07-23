# Admin Portal Implementation Plan

## Priority

The admin portal should support content and product operations while the iOS app remains local-first with no required login. The static portal in `AdminPortal/` is the UI and workflow scaffold; the Supabase migrations are a future backend starting point if admin/content services move online.

## Backend Stack

- Supabase Auth for admin staff only.
- Postgres for Learn content, notification templates, remote config, announcements, and aggregate/opt-in metrics.
- Row-Level Security on admin/content tables.
- `admin_memberships` for internal roles.
- `admin_audit_log` for support/admin access records.

## Admin Roles

- `owner`: full access, role management, billing configuration.
- `admin`: users, notifications, subscriptions, product operations.
- `support`: support-gated user detail access.
- `content_editor`: Learn CMS only.

## Production Gates

1. Keep the iOS app local-first and account-free.
2. Define which content/admin tables are needed for Learn CMS and notification templates.
3. Replace portal seed data with Supabase queries for content/admin data only.
4. Add admin login.
5. Write every sensitive admin action to `admin_audit_log`.
6. Add privacy/help copy management for local data, export, and delete guidance.

## Privacy Rules

- Default dashboard metrics should be aggregate.
- User-level fasting, mood, and consumption logs are not available to admins by default.
- Export/delete flows should stay user-controlled inside the app.
- Any future analytics must be aggregate and opt-in.
