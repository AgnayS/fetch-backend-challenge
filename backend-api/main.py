from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime, timezone
from typing import List, Dict

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Transaction(BaseModel):
    payer: str
    points: int
    timestamp: datetime

    class Config:
        json_encoders = {
            datetime: lambda v: v.replace(tzinfo=timezone.utc).isoformat()
        }

class SpendPoints(BaseModel):
    points: int

transactions: List[Transaction] = []
balances: Dict[str, int] = {}

@app.post("/add")
async def add_points(transaction: Transaction):
    transaction.timestamp = transaction.timestamp.replace(tzinfo=timezone.utc)

    if transaction.points < 0:
        payer_transactions = [t for t in transactions if t.payer == transaction.payer]
        payer_transactions.sort(key=lambda x: x.timestamp)
        points_to_deduct = -transaction.points

        for t in payer_transactions:
            if points_to_deduct == 0:
                break
            if t.points > 0:
                deduction = min(t.points, points_to_deduct)
                t.points -= deduction
                points_to_deduct -= deduction

        if points_to_deduct > 0:
            raise HTTPException(status_code=400, detail="Insufficient points for this payer")
    else:
        transactions.append(transaction)

    if transaction.payer not in balances:
        balances[transaction.payer] = 0
    balances[transaction.payer] += transaction.points

    return {"message": "Points added successfully"}

@app.post("/spend")
async def spend_points(spend: SpendPoints):
    points_to_spend = spend.points
    if points_to_spend <= 0:
        raise HTTPException(status_code=400, detail="Points to spend must be positive")
    if sum(balances.values()) < points_to_spend:
        raise HTTPException(status_code=400, detail="Not enough points")

    sorted_transactions = sorted(transactions, key=lambda x: x.timestamp)

    spent_points = {}
    for transaction in sorted_transactions:
        if points_to_spend == 0:
            break

        if transaction.points > 0:
            points_spent = min(transaction.points, points_to_spend)
            points_to_spend -= points_spent

            if transaction.payer not in spent_points:
                spent_points[transaction.payer] = 0
            spent_points[transaction.payer] -= points_spent

            transaction.points -= points_spent

    for payer, points in spent_points.items():
        balances[payer] += points

    transactions[:] = [t for t in transactions if t.points != 0]

    return [{"payer": k, "points": v} for k, v in spent_points.items()]

@app.get("/balance")
async def get_balance():
    return balances

@app.post("/reset")
async def reset_data():
    global transactions, balances
    transactions = []
    balances = {}
    return {"message": "Data reset successfully"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)