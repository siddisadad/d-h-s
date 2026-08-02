# API Documentation: Employee Service

## 4.1 `GET /employees`
Retrieves a list of all active staff members.

### Output (JSON)
```json
[
  {
    "id": "E001",
    "name": "Rahul Sharma",
    "role": "Sales Manager",
    "email": "rahul@dhs.com",
    "phone": "9876543210",
    "salary": "45,000",
    "attendanceStatus": "Present"
  }
]
```

---

## 4.2 `PATCH /employees/{id}/attendance`
Updates the daily status of an employee.

### Input
```json
{
  "status": "Absent"
}
```

### Output
- `200 OK`: Status updated successfully.
