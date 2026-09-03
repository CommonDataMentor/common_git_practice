-- Витрина analytics.dm_active_users_daily: активная аудитория (DAU) по устройствам.
-- Гранулярность: день × устройство.
-- Активный пользователь — известный пользователь хотя бы с одной сессией за день (docs/metrics.md).

TRUNCATE TABLE analytics.dm_active_users_daily;

INSERT INTO analytics.dm_active_users_daily
SELECT
    s.started_at::date          AS activity_date,
    s.device,
    count(DISTINCT s.user_id)   AS dau
FROM ecom_data.sessions s
WHERE s.started_at >= current_date - interval '30 days'
  AND s.started_at < current_date
  AND s.user_id IS NOT NULL
GROUP BY s.started_at::date, s.device;
