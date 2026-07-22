# Nudge & Flow Admin Portal

This is the first admin portal scaffold for Nudge & Flow.

It is intentionally dependency-free right now so it can be opened immediately:

```bash
open AdminPortal/index.html
```

## What It Covers

- Operational overview dashboard.
- User account table.
- Subscription/entitlement overview.
- Learn article CMS surface.
- Notification template and delivery health surface.
- Export/delete privacy request queue.
- Support-aware audit log.
- Role/security checklist.

## Backend Assumption

The portal is designed for Supabase Auth + Postgres:

- User accounts live in Supabase Auth.
- Product profile and tracking data live in public tables keyed by `user_id`.
- User-owned data uses RLS.
- Admin access is role-gated through `admin_memberships`.
- Sensitive user-level log access should require a support reason and write to `admin_audit_log`.

The current UI uses seed data in `app.js`. Replace those arrays with Supabase queries once the backend project exists.
