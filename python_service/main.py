# Optional forecasting/suggestions microservice (FastAPI)
# Deploy separately; enable FeatureFlags.pythonForecastApi to consume.
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
import uvicorn

app = FastAPI(title="Gelir Gider Forecast API")

class Tx(BaseModel):
  occurred_at: int  # milliseconds
  type: str         # income|expense
  amount: float

class ForecastRequest(BaseModel):
  transactions: List[Tx]
  horizon_months: int = 1

class ForecastResponse(BaseModel):
  predicted_expense: float
  predicted_income: float
  notes: List[str] = []

@app.post("/forecast", response_model=ForecastResponse)
def forecast(data: ForecastRequest):
  # Very naive baseline: average of last N
  incomes = [t.amount for t in data.transactions if t.type == "income"]
  expenses = [t.amount for t in data.transactions if t.type == "expense"]

  avg_income = sum(incomes)/len(incomes) if incomes else 0
  avg_expense = sum(expenses)/len(expenses) if expenses else 0

  notes = []
  if avg_expense > avg_income * 0.9:
    notes.append("Expenses are close to income; consider reducing spending.")
  if avg_income == 0 and avg_expense > 0:
    notes.append("No income detected; ensure data is complete.")

  return ForecastResponse(
    predicted_expense=avg_expense,
    predicted_income=avg_income,
    notes=notes
  )

if __name__ == "__main__":
  uvicorn.run(app, host="0.0.0.0", port=8000)
