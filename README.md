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

- Supabase schema draft for a future backend/admin mode: `supabase/migrations/001_admin_foundation.sql`
- Account/sync bootstrap kept for future reference: `supabase/migrations/002_auth_sync_bootstrap.sql`
- Admin implementation plan: `docs/admin-portal.md`

The portal is currently a dependency-free static dashboard with seed data. The iOS app is now local-first with no required login, so the admin portal should focus on Learn content, notification templates, remote configuration, and aggregate/product operations unless explicit account sync is reintroduced later.

## Local-First Data

Nudge & Flow does not require an account. Users can install the app and start tracking immediately.

Current storage:
- App profile/preferences, fasting state, water, weight, mood, and onboarding state are saved on-device.
- Consumption entries are saved locally in the App Group store so the app and widget can share them.
- Export Data remains the user-controlled way to take data out of the app.

Future backup path:
- Add optional iCloud/CloudKit backup and sync.
- Keep it Apple-ID based instead of asking users to create a Nudge & Flow account.
- Keep CSV export and delete-data controls visible.

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
- No mandatory app account.
- On-device storage first.
- Optional iCloud/CloudKit backup later for restore and Apple-device sync.
- Consider Sign in with Apple only if a future web/admin user support workflow requires account identity.

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

Build a secure web admin portal for operating content and product settings without requiring app user accounts.

Recommended stack:
- Supabase Auth for admin staff only.
- Postgres for Learn content, notification templates, remote config, announcements, and aggregate metrics.
- Row-Level Security for admin/content roles.
- Role-based access for admins and support users.
- React + Vite or Next.js for the admin dashboard.

Core admin screens:
- Overview dashboard: app releases, content status, notification templates, exports, and aggregate opt-ins if analytics are added.
- Content CMS: Learn articles, categories, featured article, read-time, publish status, and behavior-triggered recommendations.
- Notifications: notification templates, stage nudges, reminder copy, and remote config.
- Privacy docs: data-locality copy, export/delete guidance, and consent language.

Important guardrails:
- Admins should not see sensitive health/lifestyle details because personal app data is local by default.
- Every admin action should be audit logged.
- Keep analytics aggregated and optional if added later.

## Near-Term Build Priority

1. Replace temporary local snapshots with SwiftData models for fasting, water, weight, mood, and consumption logs.
2. Add optional iCloud/CloudKit backup and restore.
3. Finish WidgetKit quick logging with favorite items.
4. Build the fasting timeline.
5. Add weekly review insights.
6. Keep Supabase/admin portal focused on Learn CMS and notification templates.
