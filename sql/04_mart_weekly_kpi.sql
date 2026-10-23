-- =============================================================================
-- 04_mart_weekly_kpi.sql
-- Layer   : mart
-- Purpose : Weekly revenue by category and country (revenue mix charts).
-- Grain   : ISO week x category x country
--
-- WARNING : total_orders is only valid WITHIN a category. An order containing
--           items from several categories is counted once per category, so
--           summing total_orders across categories overcounts (~41%).
--           Use mart_weekly_country_kpi for order counts and AOV.
-- =============================================================================

CREATE OR REPLACE VIEW `market-share-analysis.market_share_dev.mart_weekly_kpi` AS
SELECT
  DATE_TRUNC(DATE(created_at), ISOWEEK)                          AS week_start_date,  -- Monday of the ISO week
  FORMAT_DATE('%G-W%V', DATE_TRUNC(DATE(created_at), ISOWEEK))   AS order_week,       -- label derived from the date
  category,
  country,
  COUNT(DISTINCT order_id)                                       AS total_orders,
  SUM(sale_price)                                                AS total_revenue,
  ROUND(SUM(sale_price) / COUNT(DISTINCT order_id), 2)           AS avg_order_value
FROM `market-share-analysis.market_share_dev.int_order_line_enriched`
WHERE category IS NOT NULL
  AND country  IS NOT NULL
  -- keep consolidated weeks only: the last ~7 days of the source are still filling up
  AND DATE(created_at) < (
        SELECT DATE_TRUNC(DATE_SUB(MAX(DATE(created_at)), INTERVAL 7 DAY), ISOWEEK)
        FROM `market-share-analysis.market_share_dev.raw_orders`
      )
GROUP BY 1, 2, 3, 4;
