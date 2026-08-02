# API Documentation: Inventory Service

## 1.1 `GET /products`
Fetches a list of all products in the system.

### Input
- **Query Parameters**:
  - `category` (Optional): Filter results by category name.

### Output (JSON)
```json
[
  {
    "sku": "STEEL-TT-12",
    "name": "Tata Tiscon TMT Bars 12mm",
    "category": "Steel",
    "price": "â‚¹68.50",
    "stock": "4200",
    "unit": "Kg",
    "isLowStock": false
  }
]
```

### Errors
- `500`: Server database unavailable.

---

## 1.2 `GET /products/{sku}`
Fetches details for a specific product.

### Input
- **Path Variables**:
  - `sku`: The unique identifier for the product.

### Output
Standard Product JSON object.

### Errors
- `404`: Product not found.
