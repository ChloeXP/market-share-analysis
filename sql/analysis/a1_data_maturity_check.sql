-- =============================================================================
-- a1_data_maturity_check.sql
-- Question : the last weeks of the trend spike — real growth or immature data?
-- Finding  : orders were stable (~170-200/day) then grew ~+30-60% per day over
--            the last ~7 days. The source generator keeps back-filling recent
--            days, so the last ~7 days are not consolidated.
-- Decision : marts exclude any week touching the last 7 days of the snapshot.
-- Note     : run against the public source to observe the effect live.
-- =============================================================================

-- 1) Weekly view: completeness and future timestamps
SELECT
  DATE_TRUNC(DATE(created_at), ISOWEEK)  AS week_start_date,
  COUNT(DISTINCT DATE(created_at))       AS nb_days,       -- 7 for a full week
  COUNT(DISTINCT order_id)               AS nb_orders,
  ROUND(SUM(sale_price))                 AS revenue,
  MIN(created_at)                        AS first_order,
  MAX(created_at)                        AS last_order     -- any future timestamps?
FROM `market-share-analysis.market_share_dev.int_order_line_enriched`
WHERE DATE(created_at) >= DATE_SUB(CURRENT_DATE(), INTERVAL 10 WEEK)
GROUP BY 1
ORDER BY 1 DESC;

-- 2) Daily view: single-day jump or gradual ramp?
SELECT
  DATE(created_at)                      AS order_date,
  FORMAT_DATE('%a', DATE(created_at))   AS weekday,
  COUNT(DISTINCT order_id)              AS nb_orders,
  ROUND(SUM(sale_price))                AS revenue
FROM `market-share-analysis.market_share_dev.int_order_line_enriched`
WHERE DATE(created_at) >= DATE_SUB(CURRENT_DATE(), INTERVAL 21 DAY)
GROUP BY 1, 2
ORDER BY 1;
