-- Витрина analytics.dm_retention_cohorts: retention месячных когорт.
-- Когорта — месяц регистрации пользователя. Месяц N — N-й календарный месяц после регистрации.
-- Retention месяца N — доля когорты хотя бы с одним успешным заказом в месяце N (docs/metrics.md).
-- Обновление: еженедельно, по понедельникам.

TRUNCATE TABLE analytics.dm_retention_cohorts;

INSERT INTO analytics.dm_retention_cohorts
WITH cohorts AS (
    SELECT
        u.id                                  AS user_id,
        date_trunc('month', u.registered_at)  AS cohort_month
    FROM ecom_data.users u
),
cohort_size AS (
    SELECT cohort_month, count(*) AS users_cnt
    FROM cohorts
    GROUP BY cohort_month
),
buyers_by_month AS (
    SELECT DISTINCT
        c.cohort_month,
        o.user_id,
        (extract(year FROM age(date_trunc('month', o.created_at), c.cohort_month)) * 12
         + extract(month FROM age(date_trunc('month', o.created_at), c.cohort_month)))::int AS month_n
    FROM ecom_data.orders o
    JOIN cohorts c ON c.user_id = o.user_id
    WHERE o.status IN ('paid', 'shipped', 'delivered')
)
SELECT
    b.cohort_month::date                          AS cohort_month,
    b.month_n,
    count(*)                                      AS buyers,
    cs.users_cnt                                  AS cohort_size,
    round(count(*) * 100.0 / cs.users_cnt, 2)     AS retention_pct
FROM buyers_by_month b
JOIN cohort_size cs ON cs.cohort_month = b.cohort_month
WHERE b.month_n >= 0
GROUP BY b.cohort_month, b.month_n, cs.users_cnt;
