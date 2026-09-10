-- Вопрос продакта (10.09.2026): в каких городах доля отмен выше средней?
-- Берём август 2026 и только города, где было хотя бы 100 заказов.

SELECT
    ci.name                                                                     AS city,
    count(*)                                                                    AS orders,
    round(count(*) FILTER (WHERE o.status = 'cancelled') * 100.0 / count(*), 2) AS cancel_rate
FROM ecom_data.orders o
JOIN ecom_data.cities ci ON ci.id = o.city_id
WHERE o.created_at >= '2026-08-01'
  AND o.created_at < '2026-09-01'
GROUP BY ci.name
HAVING count(*) >= 100
ORDER BY cancel_rate DESC;
