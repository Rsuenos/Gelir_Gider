-- Supabase schema for Gelir Gider (core subset).
-- Ensure RLS is enabled on each table and seed policies from rls_policies.sql.

-- Users table is managed by Supabase auth schema.

create table if not exists wallets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  currency text not null default 'USD',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table if not exists shared_access (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references wallets(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  can_edit boolean not null default false,
  created_at timestamp with time zone default now()
);

-- Unify movements into a single table for simplicity
create table if not exists transactions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  wallet_id uuid not null references wallets(id) on delete cascade,
  type text not null check (type in ('income','expense','transfer')),
  category text not null,
  subcategory text,
  amount numeric not null,
  currency text not null default 'USD',
  credit_card_id uuid references credit_cards(id) on delete set null,
  occurred_at timestamp with time zone not null,
  description text,
  is_upcoming boolean not null default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Credit cards & debts as separate entities
create table if not exists credit_cards (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  bank_name text,
  card_name text not null,
  last4 text,
  statement_day int,
  due_day int,
  total_limit numeric,
  current_balance numeric not null default 0,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table if not exists credit_card_installments (
  id uuid primary key default gen_random_uuid(),
  card_id uuid not null references credit_cards(id) on delete cascade,
  title text not null,
  amount numeric not null,
  due_date date,
  status text not null default 'upcoming',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table if not exists debts (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  kind text not null default 'debt' check (kind in ('credit','debt')),
  credit_card_id uuid references credit_cards(id) on delete set null,
  total_amount numeric not null,
  remaining_amount numeric not null,
  monthly_payment numeric,
  next_due_date date,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Optional: budgets, notifications, forecast_cache tables can be added similarly.
