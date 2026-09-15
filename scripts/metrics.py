"""Функции расчёта продуктовых метрик.

Определения метрик — в docs/metrics.md. Функции принимают заказы
в виде словарей, как их отдаёт csv.DictReader.
"""

SUCCESS_STATUSES = {"paid", "shipped", "delivered"}


def is_success(order: dict) -> bool:
    """Успешный заказ: оплачен, отправлен или доставлен."""
    return order["status"] in SUCCESS_STATUSES


def gmv(orders: list[dict]) -> float:
    """GMV — сумма total_amount успешных заказов."""
    return round(sum(float(o["total_amount"]) for o in orders if is_success(o)), 2)


def buyers(orders: list[dict]) -> int:
    """Покупатели — уникальные пользователи с успешным заказом."""
    return len({o["user_id"] for o in orders if is_success(o)})


def cancel_rate(orders: list[dict]) -> float:
    """Доля отмен в процентах: отменённые заказы / все заказы."""
    if not orders:
        return 0.0
    cancelled = sum(1 for o in orders if o["status"] == "cancelled")
    return round(cancelled / len(orders) * 100, 2)


def aov(orders: list[dict]) -> float:
    """Средний чек (AOV): GMV / число успешных заказов."""
    success = [o for o in orders if is_success(o)]
    if not success:
        return 0.0
    return round(gmv(success) / len(success), 2)
