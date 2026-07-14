-- TaskDesk Pro — Supabase schema
-- Run this once in your Supabase project: SQL Editor → New query → paste → Run

create table if not exists public.tasks (
  id          text not null,
  user_id     uuid not null references auth.users(id) on delete cascade,
  title       text,
  due_date    date,
  priority    text,
  tag         text,
  note        text,
  created     timestamptz,
  closed      boolean default false,
  closed_date date,
  recurring   boolean default false,
  rec_id      text,
  primary key (user_id, id)
);

create table if not exists public.recurring (
  id         text not null,
  user_id    uuid not null references auth.users(id) on delete cascade,
  title      text,
  freq       text,
  weekday    int,
  start_date date,
  priority   text,
  tag        text,
  note       text,
  created    timestamptz,
  primary key (user_id, id)
);

alter table public.tasks enable row level security;
alter table public.recurring enable row level security;

-- Each signed-in user can only ever see/edit/delete their own rows.
create policy "tasks: owner access" on public.tasks
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "recurring: owner access" on public.recurring
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Helpful indexes
create index if not exists tasks_user_idx on public.tasks(user_id);
create index if not exists recurring_user_idx on public.recurring(user_id);
