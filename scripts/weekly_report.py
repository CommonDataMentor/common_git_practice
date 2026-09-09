"""Еженедельный отчёт по заказам.

Читает выгрузку data/orders_sample.csv, считает метрики по дням
и сохраняет отчёт в reports/weekly_report.md.

Запуск из корня репозитория:
    python scripts/weekly_report.py
"""

import csv
import sys
from collections import defaultdict
from pathlib import Path

from metrics import buyers, cancel_rate, gmv, is_success

ROOT = Path(__file__).resolve().parent.parent
DATA_FILE = ROOT / "data" / "orders_sample.csv"
REPORT_FILE = ROOT / "reports" / "weekly_report.md"


def money(value: float) -> str:
    """12345.6 -> '12 345.60'"""
    return f"{value:,.2f}".replace(",", " ")


def load_orders(path: Path) -> list[dict]:
    with path.open(encoding="utf-8") as f:
        return list(csv.DictReader(f))


def build_report(orders: list[dict]) -> str:
    by_day = defaultdict(list)
    for order in orders:
        by_day[order["created_at"][:10]].append(order)

    success = sum(1 for o in orders if is_success(o))
    lines = [
        "# Еженедельный отчёт по заказам",
        "",
        f"Период: {min(by_day)} — {max(by_day)}",
        "",
        f"- Заказов всего: {len(orders)}, успешных: {success}",
        f"- Покупателей: {buyers(orders)}",
        f"- GMV: {money(gmv(orders))} руб.",
        f"- Доля отмен: {cancel_rate(orders)}%",
        "",
        "| День | Заказов всего | Покупатели | GMV, руб. | Доля отмен, % |",
        "|---|---|---|---|---|",
    ]
    for day in sorted(by_day):
        day_orders = by_day[day]
        lines.append(
            f"| {day} | {len(day_orders)} | {buyers(day_orders)} | "
            f"{money(gmv(day_orders))} | {cancel_rate(day_orders)} |"
        )
    return "\n".join(lines) + "\n"


def main() -> None:
    # чтобы кириллица печаталась в любой консоли, в том числе в Git Bash на Windows
    sys.stdout.reconfigure(encoding="utf-8")
    orders = load_orders(DATA_FILE)
    report = build_report(orders)
    REPORT_FILE.parent.mkdir(exist_ok=True)
    REPORT_FILE.write_text(report, encoding="utf-8")
    print(report)
    print(f"Отчёт сохранён: {REPORT_FILE.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
