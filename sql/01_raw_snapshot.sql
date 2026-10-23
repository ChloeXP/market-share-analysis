-- =============================================================================
-- 01_raw_snapshot.sql
-- Layer   : raw
-- Purpose : Freeze the public thelook_ecommerce source into our own dataset.
-- Why     : the public dataset is regenerated daily (historical figures change
--           from one day to the next). A snapshot makes every number in the
--           dashboard and README reproducible.
-- Dialect : GoogleSQL (BigQuery)
-- =============================================================================

CREATE OR REPLACE TABLE `market-share-analysis.market_share_dev.raw_orders` AS
SELECT *, CURRENT_TIMESTAMP() AS _snapshot_at
FROM `bigquery-public-data.thelook_ecommerce.orders`;

CREATE OR REPLACE TABLE `market-share-analysis.market_share_dev.raw_order_items` AS
SELECT *, CURRENT_TIMESTAMP() AS _snapshot_at
FROM `bigquery-public-data.thelook_ecommerce.order_items`;

CREATE OR REPLACE TABLE `market-share-analysis.market_share_dev.raw_users` AS
SELECT *, CURRENT_TIMESTAMP() AS _snapshot_at
FROM `bigquery-public-data.thelook_ecommerce.users`;

CREATE OR REPLACE TABLE `market-share-analysis.market_share_dev.raw_products` AS
SELECT *, CURRENT_TIMESTAMP() AS _snapshot_at
FROM `bigquery-public-data.thelook_ecommerce.products`;
