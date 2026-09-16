-- Витрина analytics.dm_sales_daily: продажи маркетплейса по дням.
-- Гранулярность: одна строка — один день.
-- Обновление: ежедневно, полный пересчёт за последние 30 дней (dags/dm_sales_daily_dag.py).
-- Успешный заказ — статус paid, shipped или delivered (docs/metrics.md).

TRUNCATE TABLE analytics.dm_sales_daily;

INSERT INTO analytics.dm_sales_daily
SELECT
    o.created_at::date              AS order_date,
    count(*)                        AS orders,
    count(DISTINCT o.user_id)       AS buyers,
    sum(o.total_amount)             AS gmv,
    round(avg(o.total_amount))      AS avg_check
FROM ecom_data.orders o
WHERE o.created_at >= current_date - interval '30 days'
  AND o.created_at < current_date
  AND o.status IN ('paid', 'shipped', 'delivered')
GROUP BY o.created_at::date;
