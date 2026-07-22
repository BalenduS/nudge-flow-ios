# Nudge & Flow

Nudge & Flow is an iOS fasting and consumption-pattern app built around a simple idea: help people notice their rhythms without making self-tracking feel heavy.

The app currently focuses on fasting windows, stage nudges, quick consumption logging, water intake, progress views, learning content, and a WidgetKit quick-log surface.

## Admin Portal

The repo now includes an admin portal scaffold in `AdminPortal/`.

Open the current prototype:

```bash
open AdminPortal/index.html
```

Backend foundation:

- Supabase schema draft: `supabase/migrations/001_admin_foundation.sql`
- Account/sync bootstrap: `supabase/migrations/002_auth_sync_bootstrap.sql`
- Admin implementation plan: `docs/admin-portal.md`

The portal is currently a dependency-free static dashboard with seed data. It models the real screens and workflows: overview, users, subscriptions, Learn CMS, notifications, privacy requests, audit log, and settings. Production wiring should happen after the Supabase project is created and the app has live credentials.

## Supabase Setup

The iOS app now has an optional Supabase Auth + sync layer.

1. Create a Supabase project.
2. Run the SQL migrations in order:
   - `supabase/migrations/001_admin_foundation.sql`
   - `supabase/migrations/002_auth_sync_bootstrap.sql`
3. Copy your project URL and anon key into `NudgeFlow/Config/SupabaseConfig.swift`.
4. In Supabase Auth, start with email/password enabled.
5. Run the app, open Profile, and use Account to create or sign in.

Current sync coverage:
- Profile row with display name, email, units, and Free Plan.
- Consumption entries from app/widget-backed local logs.
- Manual "Sync Now" from Profile.
- Automatic sync after Track tab consumption/water logs when signed in.

Still to wire:
- Fasting sessions.
- Weight and mood entries.
- Pulling remote history back down onto a new device.
- Admin portal live queries and admin login.

## Most Exciting Feature Ideas

### 1. Export Data

Export fasting, water, weight, mood, and consumption logs as CSV or PDF. This is useful for personal review, nutritionist/doctor conversations, and long-term self-analysis.

Good first version:
- CSV export for raw logs.
- PDF weekly/monthly summary.
- Share sheet support.
- Optional date-range picker.

### 2. Pattern Insights

Turn logs into useful observations, not guilt. Examples:
- “Coffee after 4 PM appears on 4 of your last 7 low-sleep days.”
- “Your longest fasts usually start after lighter dinners.”
- “Water intake drops on weekends.”
- “Snack logs cluster between 5-7 PM.”

This could become the app’s emotional core.

### 3. Adaptive Fasting Coach

Recommend small plan adjustments based on behavior:
- Suggest 14:10 after a rough week.
- Suggest 18:6 only after consistent 16:8 completion.
- Encourage rest days.
- Warn against pushing too hard if mood/energy logs trend low.

The app should feel like a coach, not a scoreboard.

### 4. Smart Stage Notifications

Go beyond fixed milestone alerts:
- Stage-specific encouragement.
- Hydration reminders during long fasts.
- “You are close to Fat Burning” pre-milestone nudges.
- Gentle break-fast reminders at the goal time.
- Notification tone based on user preference: calm, direct, playful, minimal.

### 5. Quick Logging Widget

Make common consumption logging nearly frictionless:
- One-tap Water, Coffee, Snack, Meal.
- Configurable favorite items.
- Lock Screen controls.
- Apple Watch quick actions later.

Freeform logging can still open the app, but common logs should not require app launch.

### 6. Favorites And Recents

Let users save common entries:
- “Black coffee”
- “Protein shake”
- “Lunch bowl”
- “Electrolytes”

The Track tab and widget can then show the user’s real routine instead of generic buttons.

### 7. Fasting Timeline

Create a beautiful day timeline showing:
- Fast start/end.
- Water logs.
- Coffee/drinks.
- Meals/snacks.
- Mood.
- Weight entries.

This would make patterns visible at a glance.

### 8. Break-Fast Guidance

When a fasting window ends, suggest gentle ways to break the fast:
- Hydrate first.
- Start with protein/fiber.
- Avoid going too heavy immediately after longer fasts.
- Save favorite break-fast meals.

### 9. Weekly Review

A weekly “Flow Report” could summarize:
- Total fasting hours.
- Completion consistency.
- Water average.
- Consumption timing patterns.
- Mood trend.
- One small suggestion for next week.

This is also a natural place for premium/export features later.

### 10. Calendar And Routine Awareness

Allow users to mark days as:
- Travel
- Social dinner
- Workout day
- Rest day
- Busy workday

Insights become better when the app knows the context behind behavior.

### 11. Apple Health Integration

Sync useful health-adjacent data:
- Weight.
- Water intake, if appropriate.
- Sleep duration.
- Steps/activity.

This can make pattern insights more meaningful without asking users to manually enter everything.

### 12. Account And Sync

Recommended path:
- Supabase Auth for app accounts, admin portal support, and cross-device sync.
- Email/password first while the product is early.
- Add Sign in with Apple before TestFlight/public release.
- Keep a clear local-first privacy mode for users who do not want sync.

### 13. Streaks With Compassion

Avoid brittle streak mechanics. Better ideas:
- “Consistency score” instead of pure streaks.
- Grace days.
- Comeback celebrations.
- Personal bests by plan type.

The app should reward returning, not punish missing.

### 14. Learn Content That Reacts To Behavior

Recommend articles based on logs:
- Frequent evening snacking -> hunger waves/mindset article.
- Low water -> hydration/electrolytes article.
- First 20:4 attempt -> break-fast guidance.
- Sleep disruption -> fasting and sleep article.

### 15. Privacy Controls

Because the app contains sensitive lifestyle data:
- Local-first mode.
- Delete all data.
- Export before delete.
- Clear explanation of what syncs and what stays local.

### 16. Admin Portal

Build a secure web admin portal for operating the product once accounts and sync exist.

Recommended stack:
- Supabase Auth for account management.
- Postgres for user, fasting, consumption, subscription, and support data.
- Row-Level Security for user-owned data.
- Role-based access for admins and support users.
- React + Vite or Next.js for the admin dashboard.

Core admin screens:
- Overview dashboard: active users, signups, retention, fasting starts, widget logs, exports, and notification opt-ins.
- Users: searchable user list with account status, plan, signup date, last active date, and deletion/export status.
- User detail: profile, fasting history, consumption logs, water/weight/mood history, device/widget status, and support notes.
- Subscriptions: Free Plan/Premium state, trial status, renewal/cancellation state, payment provider IDs, and entitlement history.
- Content CMS: Learn articles, categories, featured article, read-time, publish status, and behavior-triggered recommendations.
- Notifications: notification templates, stage nudges, reminder settings, delivery metrics, and opt-out rates.
- Exports & privacy: user export requests, delete requests, consent records, and audit log.
- Support tools: account lookup, account lock/disable, manual notes, and issue tags.

Important guardrails:
- Admins should not see sensitive health/lifestyle details by default; require explicit support reason to open detailed logs.
- Every admin action should be audit logged.
- Never allow admins to view raw exports without permission controls.
- Use soft-delete plus retention rules before permanent deletion.
- Keep analytics aggregated unless a support workflow needs user-level detail.

## Near-Term Build Priority

1. Create Supabase project and add credentials to `SupabaseConfig.swift`.
2. Run migrations and test account creation from Profile.
3. Add remote sync for fasting sessions, weight, mood, and water totals.
4. Replace admin portal seed data with authenticated Supabase queries.
5. Finish WidgetKit quick logging with favorite items.
6. Build the fasting timeline.
7. Add weekly review insights.
