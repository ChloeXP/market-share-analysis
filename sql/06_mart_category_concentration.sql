-- =============================================================================
-- 06_mart_category_concentration.sql
-- Layer   : mart
-- Purpose : Brand market structure within each category over the last
--           52 consolidated weeks: leader, leader share, CR5, HHI.
-- Grain   : one row per category (global — no country split, because shares
--           are ratios and must not be re-aggregated in the BI tool)
-- =============================================================================

CREATE OR REPLACE VIEW `market-share-analysis.market_share_dev.mart_category_concentration` AS
WITH cutoff AS (
  -- same consolidation rule as the other marts, anchored on the snapshot date
  SELECT DATE_TRUNC(DATE_SUB(MAX(DATE(created_at)), INTERVAL 7 DAY), ISOWEEK) AS d
  FROM `market-share-analysis.market_share_dev.raw_orders`
),
cat_brand AS (
  SELECT category, brand, SUM(sale_price) AS revenue
  FROM `market-share-analysis.market_share_dev.int_order_line_enriched`, cutoff
  WHERE category IS NOT NULL
    AND brand    IS NOT NULL
    AND DATE(created_at) <  cutoff.d                              -- exclusive end
    AND DATE(created_at) >= DATE_SUB(cutoff.d, INTERVAL 52 WEEK)  -- inclusive start: 52 full ISO weeks
  GROUP BY 1, 2
),
shares AS (
  SELECT
    *,
    revenue / SUM(revenue) OVER (PARTITION BY category)             AS share,  -- brand share within its category
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk     -- brand rank within its category
  FROM cat_brand
)
SELECT
  category,
  SUM(revenue)                              AS category_revenue,
  COUNT(*)                                  AS nb_brands,
  MAX(IF(rnk = 1, brand, NULL))             AS leader_brand,
  MAX(IF(rnk = 1, share, NULL))             AS leader_share,   -- ratio (0.11 = 11%)
  SUM(IF(rnk <= 5, share, 0))               AS cr5,            -- top-5 concentration ratio
  ROUND(10000 * SUM(POW(share, 2)))         AS hhi,            -- Herfindahl-Hirschman Index
  RANK() OVER (ORDER BY SUM(revenue) DESC)  AS revenue_rank    -- 1 = biggest category (used to show top 10)
FROM shares
GROUP BY category;
