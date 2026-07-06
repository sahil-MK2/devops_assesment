-- Supports:
--   SELECT org_id, status, COUNT(*), SUM(amount)
--   FROM hotel_bookings
--   WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days'
--   GROUP BY org_id, status;
--
-- (city, created_at) matches the WHERE clause exactly: city is filtered by
-- equality and should lead the index, created_at is a range and comes second.
-- org_id, status and amount are added via INCLUDE so the index alone can
-- satisfy the query (index-only scan) without a heap lookup per row.
CREATE INDEX IF NOT EXISTS idx_hotel_bookings_city_created_at
    ON hotel_bookings (city, created_at)
    INCLUDE (org_id, status, amount);

-- Supports lookups/joins of events for a given booking (FK access pattern).
CREATE INDEX IF NOT EXISTS idx_booking_events_booking_id
    ON booking_events (booking_id);
