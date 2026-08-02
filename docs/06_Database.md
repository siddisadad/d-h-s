# 06 Database Documentation: Firestore & Cloud Schema

## 6.1 Database Strategy
DCI ERP uses a hybrid approach: **Cloud Firestore** for flexible real-time collections and **Spring Boot (Postgres)** for heavy transactional logic (Invoices).

## 6.2 Key Collections

### Collection: `products`
**Purpose**: Master list of inventory items.
| Field | Type | Description |
| :--- | :--- | :--- |
| `sku` | String (PK) | Unique Stock Keeping Unit. |
| `name` | String | Commercial product name. |
| `category` | String | Logic group (e.g., 'Steel', 'Tools'). |
| `price` | String | Standard selling price with currency symbol. |
| `stock` | Number | Current available quantity. |
| `unit` | String | Measurement unit (Kg, Piece, Meter). |
| `isLowStock` | Boolean | True if stock < threshold. |

### Collection: `contacts`
**Purpose**: Customer and Supplier directory.
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String (PK) | Unique ID. |
| `name` | String | Business or person name. |
| `gstin` | String | Tax identification number. |
| `type` | String | 'customer' or 'supplier'. |
| `location` | String | Primary business city. |
| `balance` | String | Current outstanding amount. |

### Collection: `activities`
**Purpose**: Audit log of system events.
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Auto-gen. |
| `title` | String | Short event summary. |
| `subtitle` | String | Event details (e.g., SKU and amount). |
| `timestamp` | DateTime | When it occurred. |
| `type` | String | Enum: 'sale', 'purchase', 'adjustment', 'login'. |

## 6.3 Relationships
*   **Invoice -> Contact**: Invoices store the `contactId` to link sales to specific customers.
*   **Activity -> User**: Activities are linked to the `userId` of the person who performed the action.

## 6.4 Security Rules (Firebase)
```javascript
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated staff can read/write data
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Specific restriction for profit data
    match /analytics/{doc} {
      allow read: if request.auth.token.role == 'Admin';
    }
  }
}
```

## 6.5 Example JSON (Product)
```json
{
  "sku": "STEEL-TT-12",
  "name": "Tata Tiscon TMT Bars 12mm",
  "category": "Steel",
  "price": "â‚¹68.50",
  "stock": 4200,
  "unit": "Kg",
  "isLowStock": false
}
```
