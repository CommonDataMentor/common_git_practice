-- Витрина analytics.dm_funnel_daily: воронка покупки по дням.
-- Шаги: view_item → add_to_cart → begin_checkout → purchase.
-- Гранулярность: одна строка — один день.
-- На каждом шаге считаем уникальные сессии, а не события (docs/metrics.md).

TRUNCATE TABLE analytics.dm_funnel_daily;

INSERT INTO analytics.dm_funnel_daily
SELECT
    e.event_ts::date                                                              AS event_date,
    count(DISTINCT e.session_id) FILTER (WHERE e.event_type = 'view_item')        AS views,
    count(DISTINCT e.session_id) FILTER (WHERE e.event_type = 'add_to_cart')      AS carts,
    count(DISTINCT e.session_id) FILTER (WHERE e.event_type = 'begin_checkout')   AS checkouts,
    count(DISTINCT e.session_id) FILTER (WHERE e.event_type = 'purchase')         AS purchases
FROM ecom_data.events e
WHERE e.event_ts >= current_date - interval '30 days'
  AND e.event_ts < current_date
GROUP BY e.event_ts::date;
