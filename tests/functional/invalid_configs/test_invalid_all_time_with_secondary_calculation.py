from struct import pack
import os
import pytest
from dbt.tests.util import run_dbt

# our file contents
from tests.functional.fixtures import (
    fact_orders_source_csv,
    fact_orders_sql,
    fact_orders_yml,
)

# models/base_sum_metric.sql
base_sum_metric_sql = """
select *
from 
{{ metrics.calculate(metric('base_sum_metric'), 
    grain='all_time',
    secondary_calculations=[
        metrics.period_over_period(comparison_strategy="difference", interval=1, alias = "1mth")
    ]
    )
}}
"""

# models/base_sum_metric.yml
base_sum_metric_yml = """
version: 2 

metrics:
  - name: base_sum_metric
    model: ref('fact_orders')
    label: Total Discount ($)
    timestamp: order_date
    time_grains: [day, week, month, all_time]
    type: sum
    sql: order_total
    dimensions:
      - had_discount
      - order_country
"""


class TestInvalidAllTimeWithSecondaryCalculations:

    # configuration in dbt_project.yml
    @pytest.fixture(scope="class")
    def project_config_update(self):
        return {
          "name": "example",
          "models": {"+materialized": "table"}
        }

    # install current repo as package
    @pytest.fixture(scope="class")
    def packages(self):
        return {
            "packages": [
                {"local": os.getcwd()}
                ]
        }


    # everything that goes in the "seeds" directory
    @pytest.fixture(scope="class")
    def seeds(self):
        return {
            "fact_orders_source.csv": fact_orders_source_csv
        }

    # everything that goes in the "models" directory
    @pytest.fixture(scope="class")
    def models(self):
        return {
            "fact_orders.sql": fact_orders_sql,
            "fact_orders.yml": fact_orders_yml,
            "base_sum_metric.sql": base_sum_metric_sql,
            "base_sum_metric.yml": base_sum_metric_yml
        }

    def test_build_completion(self,project,):
        # running deps to install package
        results = run_dbt(["deps"])
        results = run_dbt(["seed"])

        # Here we expect the run to fail because the incorrect
        # time grain won't allow it to compile
        results = run_dbt(["run"], expect_pass = False)