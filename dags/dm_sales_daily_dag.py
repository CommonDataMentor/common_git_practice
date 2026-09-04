"""DAG analytics__dm_sales_daily: каждый день пересчитывает витрину продаж.

SQL витрины лежит в sql/marts/dm_sales_daily.sql, DAG только запускает его.
"""

from datetime import datetime

from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

with DAG(
    dag_id="analytics__dm_sales_daily",
    description="Витрина продаж по дням: полный пересчёт за последние 30 дней",
    start_date=datetime(2026, 9, 1),
    schedule="@daily",
    catchup=False,
    max_active_runs=1,
    template_searchpath=["/opt/airflow/repo/sql/marts"],
    tags=["analytics", "marts"],
    default_args={"owner": "analytics", "retries": 1},
) as dag:
    refresh_dm_sales_daily = SQLExecuteQueryOperator(
        task_id="refresh_dm_sales_daily",
        conn_id="pg_common_edu",
        sql="dm_sales_daily.sql",
    )
