# API Documentation: Finance Service

## 5.1 `GET /finance/transactions`
Retrieves the global cash book history.

### Output (JSON)
```json
[
  {
    "id": 101,
    "title": "Sale - INV001",
    "category": "Income",
    "amount": 45000.0,
    "date": "2026-08-01T14:30:00Z",
    "paymentMode": "Cash"
  }
]
```

---

## 5.2 `POST /finance/transactions`
Records a new financial entry (Income/Expense).

### Input (JSON Body)
```json
{
  "title": "Monthly Rent",
  "category": "Expense",
  "amount": 12000.0,
  "date": "2026-08-02T09:00:00Z",
  "paymentMode": "Bank"
}
```

### Output
- `201 Created`: Transaction recorded.
