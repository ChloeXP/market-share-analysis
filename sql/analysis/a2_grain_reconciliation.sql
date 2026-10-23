-- =============================================================================
-- a2_grain_reconciliation.sql
-- Question : is the order count in the category-grain mart overstated?
-- Finding  : 125,789 orders (category grain) vs 89,105 true orders -> +41%
--            overcount. Revenue reconciles exactly (7,746,121) between marts.
-- Impact   : AOV was understated by ~30% ($61.6 instead of $86.9).
-- =============================================================================

SELECT
  (SELECT SUM(total_orders)  FROM `market-share-analysis.market_share_dev.mart_weekly_kpi`)         AS orders_category_grain,
  (SELECT SUM(total_orders)  FROM `market-share-analysis.market_share_dev.mart_weekly_country_kpi`) AS orders_true,
  (SELECT SUM(total_revenue) FROM `market-share-analysis.market_share_dev.mart_weekly_kpi`)         AS revenue_a,
  (SELECT SUM(total_revenue) FROM `market-share-analysis.market_share_dev.mart_weekly_country_kpi`) AS revenue_b;
