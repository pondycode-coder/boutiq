-- Supabase schema for the cash register POS.
-- Run this in the Supabase SQL editor. Tables match the local Hive models.

create table if not exists public.products (
  id text primary key,
  name text not null default '',
  category text not null default '',
  price double precision not null default 0,
  unit text not null default '',
  description text,
  image_url text,
  stock_quantity integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.clients (
  id text primary key,
  name text not null default '',
  name_fr text not null default '',
  client_type text not null default '',
  region text not null default '',
  division text not null default '',
  subdivision text not null default '',
  address text not null default '',
  phone text not null default '',
  email text,
  contact_person text not null default '',
  credit_limit double precision not null default 0,
  current_balance double precision not null default 0,
  payment_terms_days integer not null default 0,
  preferred_payment_method text not null default '',
  assigned_route_id text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.users (
  id text primary key,
  name text not null default '',
  phone text not null default '',
  email text,
  pin text not null default '',
  role text not null default 'salesperson',
  vendor_id text,
  store_id text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id text primary key,
  store_id text not null default '',
  vendor_id text not null default '',
  status text not null default 'paid',
  payment_method text not null default 'cash',
  payment_status text not null default 'paid',
  subtotal double precision not null default 0,
  vat_amount double precision not null default 0,
  total_amount double precision not null default 0,
  notes text,
  client_id text,
  salesperson_id text,
  cash_payment_id text,
  confirmed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id text primary key,
  order_id text not null,
  product_id text not null,
  vendor_id text not null default '',
  quantity integer not null default 1,
  unit_price double precision not null default 0,
  vat_rate double precision not null default 0,
  line_subtotal double precision not null default 0,
  line_vat_amount double precision not null default 0,
  line_total double precision not null default 0
);

create table if not exists public.cash_payments (
  id text primary key,
  order_id text not null,
  store_id text not null default '',
  client_id text,
  salesperson_id text,
  amount_tendered double precision not null default 0,
  change_amount double precision not null default 0,
  paid_at timestamptz not null default now(),
  notes text
);

-- MVP: RLS is disabled so the anon key has full access.
-- Before production: enable Row Level Security per table, add
-- store_id columns, create policies by store, and use per-user auth.
-- alter table public.products enable row level security;
-- alter table public.clients enable row level security;
-- alter table public.users enable row level security;
-- alter table public.orders enable row level security;
-- alter table public.order_items enable row level security;
-- alter table public.cash_payments enable row level security;