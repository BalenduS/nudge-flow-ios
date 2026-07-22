-- Allows newly authenticated users to create their own profile and subscription rows.
-- Keeps admin visibility under the existing RLS helper policies from 001.

create policy profiles_user_insert on public.profiles
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy subscriptions_user_insert on public.subscriptions
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create unique index if not exists subscriptions_user_plan_active_idx
  on public.subscriptions (user_id, plan)
  where canceled_at is null;
