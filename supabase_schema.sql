-- NORVEN production-oriented Supabase schema.
-- Run after creating a Supabase project.
-- Never expose the service-role key in the website.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  role text not null default 'customer' check (role in ('customer','admin')),
  created_at timestamptz default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  parent_id uuid references public.categories(id) on delete set null,
  image_url text,
  sort_order int default 0,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique not null,
  description text,
  specifications jsonb default '{}'::jsonb,
  category_id uuid references public.categories(id) on delete set null,
  price numeric(12,2) not null default 0,
  mrp numeric(12,2) default 0,
  stock int not null default 0,
  sku text unique,
  images jsonb default '[]'::jsonb,
  video_url text,
  sizes jsonb default '[]'::jsonb,
  colors jsonb default '[]'::jsonb,
  rating numeric(3,2) default 0,
  reviews_count int default 0,
  featured boolean default false,
  homepage_order int default 999999,
  active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  label text default 'Home',
  full_name text not null,
  phone text not null,
  address_line text not null,
  city text not null,
  state text not null,
  pincode text not null,
  is_default boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  customer_name text not null,
  mobile text not null,
  address_line text not null,
  city text not null,
  state text not null,
  pincode text not null,
  items jsonb not null default '[]'::jsonb,
  subtotal numeric(12,2) not null default 0,
  shipping numeric(12,2) not null default 0,
  discount numeric(12,2) not null default 0,
  total numeric(12,2) not null default 0,
  payment_method text not null check (payment_method in ('COD','UPI','QR','GATEWAY')),
  payment_status text not null default 'pending',
  order_status text not null default 'New',
  payment_reference text,
  courier_name text,
  tracking_number text,
  delivery_otp_status text default 'not_started',
  cancelled_reason text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  stars int not null check (stars between 1 and 5),
  title text,
  body text,
  photo_urls jsonb default '[]'::jsonb,
  video_url text,
  helpful_count int default 0,
  verified_purchase boolean default false,
  approved boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.coupons (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  type text not null check (type in ('percent','fixed')),
  value numeric(12,2) not null,
  min_order numeric(12,2) default 0,
  max_discount numeric(12,2),
  active boolean default true,
  starts_at timestamptz,
  ends_at timestamptz
);

create table if not exists public.site_settings (
  id int primary key default 1,
  store_name text default 'NORVEN',
  tagline text default 'New Vision Everyday Needs',
  logo_url text,
  banner_url text,
  upi_id text,
  qr_url text,
  whatsapp text,
  email text,
  free_shipping_threshold numeric(12,2) default 999,
  shipping_flat numeric(12,2) default 60,
  homepage_title text default 'Shop by Category',
  homepage_subtitle text default 'Explore'
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  title text not null,
  message text not null,
  read boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.kb_settings (
  id int primary key default 1,
  gateway_name text,
  gateway_public_config jsonb default '{}'::jsonb,
  kyc_status text default 'not_started',
  courier_provider text,
  courier_public_config jsonb default '{}'::jsonb
);

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.addresses enable row level security;
alter table public.orders enable row level security;
alter table public.reviews enable row level security;
alter table public.coupons enable row level security;
alter table public.site_settings enable row level security;
alter table public.notifications enable row level security;
alter table public.kb_settings enable row level security;

create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

-- Public catalogue/settings.
drop policy if exists "public read active products" on public.products;
create policy "public read active products" on public.products for select using (active = true or public.is_admin());

drop policy if exists "public read categories" on public.categories;
create policy "public read categories" on public.categories for select using (active = true or public.is_admin());

drop policy if exists "public read site settings" on public.site_settings;
create policy "public read site settings" on public.site_settings for select using (true);

-- Customers only see their own private data.
drop policy if exists "own addresses" on public.addresses;
create policy "own addresses" on public.addresses for all using (auth.uid() = user_id or public.is_admin()) with check (auth.uid() = user_id or public.is_admin());

drop policy if exists "own orders" on public.orders;
create policy "own orders" on public.orders for select using (auth.uid() = user_id or public.is_admin());

drop policy if exists "own notifications" on public.notifications;
create policy "own notifications" on public.notifications for select using (auth.uid() = user_id or public.is_admin());

drop policy if exists "approved reviews public" on public.reviews;
create policy "approved reviews public" on public.reviews for select using (approved = true or user_id = auth.uid() or public.is_admin());

-- Admin full management.
drop policy if exists "admin categories" on public.categories;
create policy "admin categories" on public.categories for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin products" on public.products;
create policy "admin products" on public.products for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin orders" on public.orders;
create policy "admin orders" on public.orders for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin reviews" on public.reviews;
create policy "admin reviews" on public.reviews for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin coupons" on public.coupons;
create policy "admin coupons" on public.coupons for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin site settings" on public.site_settings;
create policy "admin site settings" on public.site_settings for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin kb settings" on public.kb_settings;
create policy "admin kb settings" on public.kb_settings for all using (public.is_admin()) with check (public.is_admin());

insert into public.site_settings(id) values (1) on conflict (id) do nothing;
insert into public.kb_settings(id) values (1) on conflict (id) do nothing;
