-- Enable RLS
alter table wallets enable row level security;
alter table shared_access enable row level security;
alter table transactions enable row level security;
alter table credit_cards enable row level security;
alter table debts enable row level security;

-- Policies: Owner or shared can read/write according to permissions.

-- Wallets: owner full access
create policy "wallets_owner_select" on wallets
for select using (auth.uid() = owner_id);
create policy "wallets_owner_ins" on wallets
for insert with check (auth.uid() = owner_id);
create policy "wallets_owner_upd" on wallets
for update using (auth.uid() = owner_id);
create policy "wallets_owner_del" on wallets
for delete using (auth.uid() = owner_id);

-- Shared access join: allow users listed in shared_access to select wallet
create policy "wallets_shared_select" on wallets
for select using (
  exists (select 1 from shared_access s where s.wallet_id = wallets.id and s.user_id = auth.uid())
);

-- shared_access: an owner can manage shares, sharee can read its own row
create policy "shared_select" on shared_access
for select using (
  user_id = auth.uid() or
  exists (select 1 from wallets w where w.id = wallet_id and w.owner_id = auth.uid())
);
create policy "shared_ins" on shared_access
for insert with check (
  exists (select 1 from wallets w where w.id = wallet_id and w.owner_id = auth.uid())
);
create policy "shared_upd" on shared_access
for update using (
  exists (select 1 from wallets w where w.id = wallet_id and w.owner_id = auth.uid())
);
create policy "shared_del" on shared_access
for delete using (
  exists (select 1 from wallets w where w.id = wallet_id and w.owner_id = auth.uid())
);

-- Transactions: owner or sharee can select; write allowed if owner or sharee with can_edit
create policy "tx_select" on transactions
for select using (
  owner_id = auth.uid() or
  exists (
    select 1 from shared_access s
    join wallets w on w.id = s.wallet_id
    where transactions.wallet_id = s.wallet_id and s.user_id = auth.uid()
  )
);

create policy "tx_insert" on transactions
for insert with check (
  owner_id = auth.uid() or
  exists (
    select 1 from shared_access s
    where s.wallet_id = transactions.wallet_id and s.user_id = auth.uid() and s.can_edit = true
  )
);

create policy "tx_update" on transactions
for update using (
  owner_id = auth.uid() or
  exists (
    select 1 from shared_access s
    where s.wallet_id = transactions.wallet_id and s.user_id = auth.uid() and s.can_edit = true
  )
);

create policy "tx_delete" on transactions
for delete using (
  owner_id = auth.uid() or
  exists (
    select 1 from shared_access s
    where s.wallet_id = transactions.wallet_id and s.user_id = auth.uid() and s.can_edit = true
  )
);

-- Credit cards & debts: owner only (can be extended to shared)
create policy "cc_owner_select" on credit_cards
for select using (owner_id = auth.uid());
create policy "cc_owner_cud" on credit_cards
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "debts_owner_select" on debts
for select using (owner_id = auth.uid());
create policy "debts_owner_cud" on debts
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
