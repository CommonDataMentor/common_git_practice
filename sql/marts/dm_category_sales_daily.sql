-- Витрина analytics.dm_category_sales_daily: продажи по категориям по дням.
-- Гранулярность: день × категория 3-го уровня.
-- items_total — сумма позиций до скидки (item_total), поэтому с GMV из dm_sales_daily не сравниваем.

TRUNCATE TABLE analytics.dm_category_sales_daily;

INSERT INTO analytics.dm_category_sales_daily
SELECT
    o.created_at::date              AS order_date,
    p.category_id,
    count(DISTINCT o.id)            AS orders,
    sum(oi.quantity)                AS items,
    sum(oi.item_total)              AS items_total
FROM ecom_data.orders o
JOIN ecom_data.order_items oi ON oi.order_id = o.id
JOIN ecom_data.products p     ON p.id = oi.product_id
WHERE o.created_at >= current_date - interval '30 days'
  AND o.created_at < current_date
  AND o.status IN ('paid', 'shipped', 'delivered')
GROUP BY o.created_at::date, p.category_id;
