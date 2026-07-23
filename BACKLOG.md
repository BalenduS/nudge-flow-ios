# Backlog

## Monetization

- Reintroduce the Premium paywall after the core fasting, consumption logging, and account flows are stable.
- Decide the paid feature boundary before implementation. Early candidates: adaptive fasting plans, deeper analytics, recipe/article library expansion, and exportable reports.

## Accounts

- Do not require app account creation or sign-in.
- Add optional iCloud/CloudKit backup for restore and Apple-device sync.
- Keep Sign in with Apple and Supabase Auth as future options only if cross-platform accounts become necessary.

## Admin Portal

- Build an internal web dashboard for content and product operations.
- Recommended backend path: Supabase Auth for admins only + Postgres + Row-Level Security.
- Add role-based access: owner, admin, support, content editor.
- Add admin screens for overview, Learn content, notification templates, remote config, announcements, and audit logs.
- Add a content CMS for Learn articles and behavior-triggered article recommendations.
- Do not expose user-level fasting/consumption details by default; app data is local-first.
- Track only aggregate, opt-in metrics if analytics are added later.

## Widgets

- Add a WidgetKit extension for fast logging from the Home Screen or Lock Screen.
- Store consumption entries in shared local persistence before the widget ships, likely SwiftData plus an App Group container.
- Reuse the in-app consumption categories: Meal, Snack, Water, Drink, and Caffeine.
- Add App Intents for quick actions such as "Log Water" and "Log Consumption" once the shared store exists.
