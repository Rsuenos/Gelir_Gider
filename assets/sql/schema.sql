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

-- Kart hareketleri ve taksit planı
create table if not exists credit_card_transactions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  card_id uuid not null references credit_cards(id) on delete cascade,
  expense_id uuid null,                         -- Gider ile ilişki (varsa)
  flow text not null check (flow in ('spend','payment')),
  amount numeric(14,2) not null check (amount >= 0),
  description text,
  -- Taksit alanları:
  installment_total int null check (installment_total between 2 and 12),
  installment_no int null,                      -- 1..N
  -- Tahakkuk/işleme zamanı:
  is_posted boolean not null default false,     -- ilgili ay geldiyse işlenmiş mi
  due_date date not null,                       -- taksit/işlem tarihi
  posted_at timestamptz null,                   -- işlenme anı
  created_at timestamptz not null default now()
);

-- İndeksler
create index if not exists idx_cct_card_due on credit_card_transactions(card_id, due_date);
create index if not exists idx_cct_posted on credit_card_transactions(is_posted, due_date);
create index if not exists idx_cct_owner on credit_card_transactions(owner_id);

-- Gelecek işlemler view'ı
create or replace view credit_card_upcoming as
select *
from credit_card_transactions
where is_posted = false and due_date > current_date
order by due_date asc;

-- Optional: budgets, notifications, forecast_cache tables can be added similarly.
