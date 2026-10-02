NORVEN FULL FEATURE PACKAGE
============================

This package is a substantial full-feature storefront + admin dashboard starter for the existing NORVEN GitHub Pages site.

IMPORTANT PRODUCTION NOTE
-------------------------
A GitHub Pages static site cannot securely hold a server secret, process real payments, send trusted OTP/SMS, or enforce private admin permissions by itself.
This package therefore includes:
1) A complete client-side storefront/admin UI and demo data layer so the flows can be tested immediately.
2) A Supabase schema + configuration adapter for real authentication, database, storage and RLS.
3) Clear future integration points for payment gateways, courier tracking/OTP and notifications.

DO NOT put a Supabase service-role key in the browser.

CUSTOMER SIDE
-------------
- Premium dark/gold NORVEN storefront
- Search, category filters, sorting
- Product detail pages
- Multiple product images
- Product video URL
- Description/specifications
- Price/MRP/discount
- Stock, SKU
- Size/color variants
- Related products
- Wishlist
- Cart and quantity controls
- Coupon/offers
- Shipping/free-shipping rules
- Account/profile
- Multiple addresses
- Order history/details/status
- Invoice/receipt view
- COD
- UPI ID / manual QR
- Payment confirmation state
- Ratings/reviews with photo/video URL fields
- Verified purchase flag
- Helpful review button
- Customer notifications UI
- About/contact/policy pages
- WhatsApp support
- Return/refund controls are intentionally HIDDEN on customer side for now

ADMIN
-----
Admin is NOT linked in the customer header.
Open admin.html directly. In production, connect Supabase Auth and RLS.

Dashboard sections:
- Overview / sales statistics
- Products
- Orders
- Customers
- Reviews
- Categories / subcategories
- Coupons
- Offers
- Homepage sections
- Banners
- Ads/promotions
- Featured products + homepage order
- Store settings
- Shipping settings
- Payment / UPI / QR
- KYC & Payments future-ready section
- Notifications
- Return & Refund FUTURE section (inactive)
- Security / Supabase setup information

PRODUCT ADMIN
-------------
- Add/edit/delete
- 4–6 image URLs
- Video URL
- Description/specifications
- Price/MRP/discount
- Stock
- SKU
- category/subcategory
- size variants
- color variants
- rating/review count
- featured/homepage ordering

ORDER ADMIN
-----------
Statuses:
New -> Confirmed -> Packed -> Shipped -> Out for Delivery -> Delivered
Also Cancelled, Returned, Refunded.

COURIER / OTP
-------------
This package does not invent a NORVEN delivery-boy app. Third-party courier APIs can be connected later.
The schema has courier/tracking fields and delivery OTP state for future integrations.

REAL SUPABASE SETUP
-------------------
Edit supabase-config.js with your Supabase URL and anon key.
Then run supabase_schema.sql in the Supabase SQL editor.
Create your admin account in Supabase Auth and assign role=admin in public.profiles.
Enable Storage buckets according to the SQL file.
Never put the service-role key in client files.

DEMO MODE
---------
Without Supabase configuration the site uses local demo storage so all major UI flows can be tested.
Demo data is local to the browser and is NOT a secure production database.

UPLOAD
------
Upload the extracted files to the EXISTING:
norvenofficial01-cloud/norven-store
Replace matching old files. Do not upload this ZIP itself.


TEMP ADMIN LOGIN (before Supabase)
Email: norvenofficial01@gmail.com
Password: Norven@2026
This temporary client-side lock is not production-grade security; replace with Supabase Auth before real customer data/payment launch.
