-- Seed data: multiple orgs, multiple cities, multiple statuses,
-- 200+ generic bookings spread over the last ~180 days, plus a guaranteed
-- batch of "delhi" bookings inside the last 30 days so the target query in
-- README.md has real rows to return. Also seeds booking_events for a subset
-- of bookings.

-- Generic bookings across all cities/orgs/statuses.
INSERT INTO hotel_bookings (org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at)
SELECT
    (ARRAY[
        '11111111-1111-1111-1111-111111111111',
        '22222222-2222-2222-2222-222222222222',
        '33333333-3333-3333-3333-333333333333',
        '44444444-4444-4444-4444-444444444444',
        '55555555-5555-5555-5555-555555555555'
    ]::uuid[])[1 + floor(random() * 5)::int],
    'HTL-' || lpad((1 + floor(random() * 50))::int::text, 4, '0'),
    (ARRAY['delhi', 'mumbai', 'bangalore', 'pune', 'goa'])[1 + floor(random() * 5)::int],
    d.checkin,
    d.checkin + (1 + floor(random() * 5))::int,
    round((random() * 50000 + 1000)::numeric, 2),
    (ARRAY['confirmed', 'cancelled', 'pending', 'completed', 'refunded'])[1 + floor(random() * 5)::int],
    d.created_at
FROM (
    SELECT
        current_date - (floor(random() * 180))::int AS checkin,
        now() - (floor(random() * 90) * interval '1 day') AS created_at
    FROM generate_series(1, 6000)
) d;

-- Guaranteed "delhi, last 30 days" bookings across multiple orgs/statuses so
-- the optimized query in README.md has a realistic, non-empty result set.
INSERT INTO hotel_bookings (org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at)
SELECT
    (ARRAY[
        '11111111-1111-1111-1111-111111111111',
        '22222222-2222-2222-2222-222222222222',
        '33333333-3333-3333-3333-333333333333',
        '44444444-4444-4444-4444-444444444444',
        '55555555-5555-5555-5555-555555555555'
    ]::uuid[])[1 + floor(random() * 5)::int],
    'HTL-' || lpad((1 + floor(random() * 50))::int::text, 4, '0'),
    'delhi',
    current_date - (floor(random() * 10))::int,
    current_date - (floor(random() * 10))::int + 2,
    round((random() * 50000 + 1000)::numeric, 2),
    (ARRAY['confirmed', 'cancelled', 'pending', 'completed', 'refunded'])[1 + floor(random() * 5)::int],
    now() - (floor(random() * 29) * interval '1 day')
FROM generate_series(1, 600);

-- Booking events for roughly half of all bookings (1-3 events each).
INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT
    b.id,
    (ARRAY['booking_created', 'payment_received', 'checkin_completed', 'checkout_completed', 'booking_cancelled'])[1 + floor(random() * 5)::int],
    jsonb_build_object('source', 'seed', 'amount', b.amount, 'status', b.status),
    b.created_at + (floor(random() * 5) * interval '1 hour')
FROM hotel_bookings b, generate_series(1, (1 + floor(random() * 3))::int)
WHERE random() < 0.5;
