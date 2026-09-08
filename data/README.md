# Выгрузки для локальных проверок

Небольшие выгрузки из базы `common_edu_db` (схема `ecom_data`) за неделю 7–13 сентября 2026. Нужны, чтобы проверять скрипты из `scripts/` без доступа к базе.

| Файл | Строк | Колонки |
|---|---|---|
| `orders_sample.csv` | 147 | `id`, `user_id`, `created_at`, `status`, `total_amount`, `discount_amount` |
| `events_sample.csv` | 242 | `id`, `session_id`, `user_id`, `event_ts`, `event_type`, `product_id` |

Большие выгрузки сюда не кладём: для них есть папка `data/raw/`, она указана в `.gitignore`.
