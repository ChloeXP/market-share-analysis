-- =============================================================================
-- 02_stg_orders.sql
-- Layer   : staging
-- Purpose : Clean orders — keep only orders that generated real revenue.
-- Grain   : one row per order
-- =============================================================================

CREATE OR REPLACE VIEW `market-share-analysis.market_share_dev.stg_orders` AS
SELECT
  order_id,
  user_id,
  status,
  gender,
  created_at,
  returned_at,
  shipped_at,
  delivered_at,
  num_of_item
FROM `market-share-analysis.market_share_dev.raw_orders`
WHERE status NOT IN ('Cancelled', 'Returned');
