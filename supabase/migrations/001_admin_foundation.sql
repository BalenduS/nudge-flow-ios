-- Nudge & Flow admin/backend foundation.
-- Designed for Supabase Auth + Postgres with RLS enabled on user-owned data.

create extension if not exists "pgcrypto";

create type public.admin_role as enum ('owner', 'admin', 'support', 'content_editor');
create type public.subscription_plan as enum ('free', 'premium', 'trial');
create type public.privacy_request_type as enum ('export', 'delete', 'consent_lookup');
create type public.privacy_request_status as enum ('open', 'processing', 'completed', 'rejected');
create type public.consumption_category as enum ('meal', 'snack', 'water', 'drink', 'caffeine');

create table public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  email text,
  plan subscription_plan not null default 'free',
  units text not null default 'metric' check (units in ('metric', 'imperial')),
  created_at timestamptz not null default now(),
  last_active_at timestamptz,
  disabled_at timestamptz
);

create table public.admin_memberships (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role admin_role not null,
  created_at timestamptz not null default now()
);

create table public.fasting_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_label text not null,
  plan_hours int not null check (plan_hours between 1 and 48),
  started_at timestamptz not null,
  ended_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.consumption_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  category consumption_category not null,
  consumed_at timestamptz not null,
  source text not null default 'app' check (source in ('app', 'widget', 'import')),
  created_at timestamptz not null default now()
);

create table public.weight_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  weight_kg numeric(6, 2) not null check (weight_kg > 0),
  logged_at timestamptz not null,
  created_at timestamptz not null default now()
);

create table public.mood_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  mood text not null check (mood in ('Great', 'Good', 'Okay', 'Low', 'Bad')),
  logged_at timestamptz not null,
  created_at timestamptz not null default now()
);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan subscription_plan not null default 'free',
  provider text,
  provider_customer_id text,
  provider_subscription_id text,
  trial_ends_at timestamptz,
  current_period_ends_at timestamptz,
  canceled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.learn_articles (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null,
  summary text not null,
  body text,
  read_minutes int not null check (read_minutes > 0),
  status text not null default 'draft' check (status in ('draft', 'published', 'scheduled', 'archived')),
  is_featured boolean not null default false,
  behavior_trigger text,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.notification_templates (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  title text not null,
  body text not null,
  tone text not null default 'calm',
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.privacy_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  request_type privacy_request_type not null,
  status privacy_request_status not null default 'open',
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  notes text
);

create table public.admin_audit_log (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references auth.users(id) on delete set null,
  target_user_id uuid references auth.users(id) on delete set null,
  action text not null,
  support_reason text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index profiles_plan_idx on public.profiles (plan);
create index profiles_last_active_at_idx on public.profiles (last_active_at desc);
create index fasting_sessions_user_id_started_at_idx on public.fasting_sessions (user_id, started_at desc);
create index consumption_entries_user_id_consumed_at_idx on public.consumption_entries (user_id, consumed_at desc);
create index consumption_entries_category_consumed_at_idx on public.consumption_entries (category, consumed_at desc);
create index weight_entries_user_id_logged_at_idx on public.weight_entries (user_id, logged_at desc);
create index mood_entries_user_id_logged_at_idx on public.mood_entries (user_id, logged_at desc);
create index subscriptions_user_id_idx on public.subscriptions (user_id);
create index privacy_requests_user_id_requested_at_idx on public.privacy_requests (user_id, requested_at desc);
create index privacy_requests_status_requested_at_idx on public.privacy_requests (status, requested_at desc);
create index admin_audit_log_actor_created_at_idx on public.admin_audit_log (actor_user_id, created_at desc);
create index admin_audit_log_target_created_at_idx on public.admin_audit_log (target_user_id, created_at desc);
create index learn_articles_status_published_at_idx on public.learn_articles (status, published_at desc);

create or replace function public.is_admin(required_role admin_role default null)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_memberships am
    where am.user_id = (select auth.uid())
      and (
        required_role is null
        or am.role = 'owner'
        or am.role = required_role
        or (required_role in ('support', 'content_editor') and am.role = 'admin')
      )
  );
$$;

alter table public.profiles enable row level security;
alter table public.admin_memberships enable row level security;
alter table public.fasting_sessions enable row level security;
alter table public.consumption_entries enable row level security;
alter table public.weight_entries enable row level security;
alter table public.mood_entries enable row level security;
alter table public.subscriptions enable row level security;
alter table public.learn_articles enable row level security;
alter table public.notification_templates enable row level security;
alter table public.privacy_requests enable row level security;
alter table public.admin_audit_log enable row level security;

create policy profiles_user_read on public.profiles
  for select to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin()));

create policy profiles_user_update on public.profiles
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy admin_memberships_owner_read on public.admin_memberships
  for select to authenticated
  using ((select public.is_admin('owner')));

create policy fasting_sessions_user_access on public.fasting_sessions
  for all to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin('support')))
  with check (user_id = (select auth.uid()));

create policy consumption_entries_user_access on public.consumption_entries
  for all to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin('support')))
  with check (user_id = (select auth.uid()));

create policy weight_entries_user_access on public.weight_entries
  for all to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin('support')))
  with check (user_id = (select auth.uid()));

create policy mood_entries_user_access on public.mood_entries
  for all to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin('support')))
  with check (user_id = (select auth.uid()));

create policy subscriptions_user_read on public.subscriptions
  for select to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin()));

create policy learn_articles_public_read on public.learn_articles
  for select to authenticated
  using (status = 'published' or (select public.is_admin('content_editor')));

create policy learn_articles_editor_write on public.learn_articles
  for all to authenticated
  using ((select public.is_admin('content_editor')))
  with check ((select public.is_admin('content_editor')));

create policy notification_templates_admin_access on public.notification_templates
  for all to authenticated
  using ((select public.is_admin('admin')))
  with check ((select public.is_admin('admin')));

create policy privacy_requests_user_read on public.privacy_requests
  for select to authenticated
  using (user_id = (select auth.uid()) or (select public.is_admin('support')));

create policy privacy_requests_user_insert on public.privacy_requests
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy admin_audit_log_admin_read on public.admin_audit_log
  for select to authenticated
  using ((select public.is_admin()));

create policy admin_audit_log_admin_insert on public.admin_audit_log
  for insert to authenticated
  with check ((select public.is_admin()));

insert into public.notification_templates (key, title, body, tone) values
  ('fat_burning', 'Fat Burning reached', 'Nice progress. Your body is shifting gears.', 'encouraging'),
  ('ketosis', 'Ketosis reached', 'You are deep into the fast now. Stay hydrated and keep going.', 'encouraging'),
  ('fat_loss', 'Fat Loss reached', 'Strong work. You have reached a key fasting milestone.', 'encouraging'),
  ('autophagy', 'Autophagy reached', 'A serious milestone. Listen to your body and finish with care.', 'calm')
on conflict (key) do nothing;
