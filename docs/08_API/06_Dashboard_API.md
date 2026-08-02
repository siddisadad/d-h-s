# API Documentation: Dashboard Service

## 6.1 `GET /dashboard/stats`
Aggregates daily operational KPIs.

### Output (JSON)
```json
{
  "sales": "â‚¹1,45,200",
  "purchases": "â‚¹82,400",
  "collections": "â‚¹92,000",
  "lowStock": "14 Items"
}
```

---

## 6.2 `GET /dashboard/revenue-trend`
Provides data points for the 7-day revenue chart.

### Output (JSON)
```json
[45.0, 52.0, 48.0, 70.0, 61.0, 85.0, 92.0]
```
