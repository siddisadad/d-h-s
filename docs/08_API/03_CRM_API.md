# API Documentation: CRM Service

## 3.1 `GET /contacts`
Retrieves the business directory.

### Input
- **Query Parameters**:
  - `type`: Either `customer` or `supplier`.

### Output (JSON)
```json
[
  {
    "id": "C123",
    "name": "Rohan Construction",
    "initials": "RC",
    "contact": "+91 9876543210",
    "gstin": "27AAACA1234A1Z5",
    "balance": "â‚¹45,820",
    "location": "Pune",
    "type": "customer"
  }
]
```

---

## 3.2 `GET /contacts/{id}/ledger`
Fetches the detailed transaction history for a specific contact.

### Output
Array of `LedgerEntry` objects including date, reference ID, and debit/credit status.
