# API Documentation: Sales Service

## 2.1 `POST /invoices`
Submits a new sales invoice to the cloud.

### Input (Request Body)
```json
{
  "id": "INV-12345",
  "customerName": "Rohan Construction",
  "date": "2026-08-02T10:00:00Z",
  "items": [
    {
      "name": "TMT Bar 12mm",
      "price": 68.5,
      "qty": 100.0,
      "gstRate": 18.0
    }
  ],
  "discount": 500.0
}
```

### Output
- `201 Created`: Invoice persisted successfully.

---

## 2.2 `GET /invoices/recent`
Retrieves a list of the most recent invoices for the dashboard activity feed.

### Output
JSON array of [Invoice Objects].
