-- =============================================================================
-- 05_mart_weekly_country_kpi.sql
-- Layer   : mart
-- Purpose : Company-level KPIs (revenue, orders, AOV) and the revenue trend.
-- Grain   : ISO week x country
--           Orders are counted at their natural grain: each order once.
--           (A user belongs to a single country, so splitting by country
--           does not double count.)
-- =============================================================================

CREATE OR REPLACE VIEW `market-share-analysis.market_share_dev.mart_weekly_country_kpi` AS
SELECT
  DATE_TRUNC(DATE(created_at), ISOWEEK)  AS week_start_date,
  country,
  COUNT(DISTINCT order_id)               AS total_orders,
  SUM(sale_price)                        AS total_revenue
FROM `market-share-analysis.market_share_dev.int_order_line_enriched`
WHERE category IS NOT NULL      -- same filters as mart_weekly_kpi -> revenues reconcile exactly
  AND country  IS NOT NULL
  AND DATE(created_at) < (
        SELECT DATE_TRUNC(DATE_SUB(MAX(DATE(created_at)), INTERVAL 7 DAY), ISOWEEK)
        FROM `market-share-analysis.market_share_dev.raw_orders`
      )
GROUP BY 1, 2;

-- AOV is computed in Looker Studio as a ratio of sums (never an average of averages):
--   AOV = SUM(total_revenue) / SUM(total_orders)
