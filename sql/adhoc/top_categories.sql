-- Вопрос продакта (21.09.2026): какие категории первого уровня дали больше всего продаж в августе?
-- Разовый запрос: результат выгрузили в таблицу и отправили категорийным менеджерам.
-- Товары висят на категориях 3-го уровня, поэтому поднимаемся по parent_id два раза.
-- items_total — сумма позиций до скидки: GMV по категориям в нашей базе не посчитать.

SELECT
    c1.name                     AS category,
    count(DISTINCT o.id)        AS orders,
    sum(oi.quantity)            AS items,
    sum(oi.item_total)          AS items_total
FROM ecom_data.orders o
JOIN ecom_data.order_items oi ON oi.order_id = o.id
JOIN ecom_data.products p     ON p.id = oi.product_id
JOIN ecom_data.categories c3  ON c3.id = p.category_id
JOIN ecom_data.categories c2  ON c2.id = c3.parent_id
JOIN ecom_data.categories c1  ON c1.id = c2.parent_id
WHERE o.created_at >= '2026-08-01'
  AND o.created_at < '2026-09-01'
  AND o.status IN ('paid', 'shipped', 'delivered')
GROUP BY c1.name
ORDER BY items_total DESC
LIMIT 10;
