# Backlog

## Monetization

- Reintroduce the Premium paywall after the core fasting, consumption logging, and account flows are stable.
- Decide the paid feature boundary before implementation. Early candidates: adaptive fasting plans, deeper analytics, recipe/article library expansion, and exportable reports.

## Accounts

- Add account creation and sign-in.
- Recommended first implementation: Sign in with Apple plus iCloud/CloudKit sync for a privacy-forward iOS app.
- Alternative implementation: Supabase Auth if cross-platform/web admin tooling is needed earlier.

## Admin Portal

- Build an internal web dashboard after accounts and synced persistence exist.
- Recommended backend path: Supabase Auth + Postgres + Row-Level Security.
- Add role-based access: owner, admin, support, content editor.
- Add admin screens for overview, users, user detail, subscriptions, Learn content, notifications, export/delete requests, and audit logs.
- Add a content CMS for Learn articles and behavior-triggered article recommendations.
- Keep user-level fasting/consumption details protected behind support-reason prompts and audit logging.
- Track aggregate metrics: active users, retention, fasting starts, widget logs, notification opt-ins, exports, and delete requests.
- Do not build the admin portal against local-only app data; ship backend sync first.

## Widgets

- Add a WidgetKit extension for fast logging from the Home Screen or Lock Screen.
- Store consumption entries in shared persistence before the widget ships, likely SwiftData plus an App Group container.
- Reuse the in-app consumption categories: Meal, Snack, Water, Drink, and Caffeine.
- Add App Intents for quick actions such as "Log Water" and "Log Consumption" once the shared store exists.
