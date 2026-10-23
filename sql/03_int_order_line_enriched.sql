-- =============================================================================
-- 03_int_order_line_enriched.sql
-- Layer   : intermediate
-- Purpose : Join order lines with product (category, brand) and user (country).
-- Grain   : one row per order line (order x product)
-- =============================================================================

CREATE OR REPLACE VIEW `market-share-analysis.market_share_dev.int_order_line_enriched` AS
SELECT
  o.order_id,
  o.user_id,
  oi.product_id,
  o.status,
  o.created_at,
  o.gender,
  oi.sale_price,      -- actual selling price of the item
  p.category,         -- product category (revenue mix / market definition)
  p.department,
  p.brand,            -- brand (market share within a category)
  u.country           -- customer country (geographic filter)
FROM      `market-share-analysis.market_share_dev.stg_orders`      o
JOIN      `market-share-analysis.market_share_dev.raw_order_items` oi ON o.order_id    = oi.order_id
LEFT JOIN `market-share-analysis.market_share_dev.raw_products`    p  ON oi.product_id = p.id
LEFT JOIN `market-share-analysis.market_share_dev.raw_users`       u  ON o.user_id     = u.id;
