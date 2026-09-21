# Backend API Contract

Base path examples use `/v1`. All protected calls require:

```http
Authorization: Bearer <access-token>
Accept: application/json
Content-Type: application/json
X-Client-Platform: flutter
```

All dates are ISO-8601 UTC. Amounts are JSON numbers in INR unless the backend
introduces an explicit currency field. Branch access is derived from the token;
`branchId` must also be validated server-side.

## Authentication host integration

The app deliberately has no authentication screen in this transaction/report
scope. The host authentication flow stores its tokens in secure storage and
hydrates `UserSessionModel` from `/v1/users/me`.

```json
{
  "userId": "USR-001",
  "userName": "Raju Kumar",
  "role": "financeManager",
  "branchId": "BR-001",
  "branchName": "Bengaluru Main"
}
```

Supported roles are `financeManager`, `warehouseManager`,
`procurementManager`, and `salesManager`.

### Refresh token

`POST /v1/auth/refresh-token`

```json
{ "refreshToken": "opaque-refresh-token" }
```

```json
{ "accessToken": "new-access-token" }
```

## Read-only transaction lookups

`GET /v1/lookups/transactions?branchId=BR-001`

```json
{
  "branches": ["Bengaluru Main"],
  "suppliers": ["Ravi Coconut Farm"],
  "customers": ["Anand Stores"],
  "warehouses": ["Main Yard"],
  "items": ["Premium Coconut"],
  "bags": ["Jute Bag"],
  "labour": ["Ramesh"],
  "expenseHeads": ["Fuel & transport"],
  "customerInvoices": ["DS-0821 • ₹32,400"],
  "supplierInvoices": ["PI-0448 • ₹74,500"]
}
```

Production implementations should return stable object IDs and labels. The
repository adapter can then map them to an `id/label` lookup model without
changing controllers or views.

## Transactions

Route values:

- `purchase-orders`
- `purchase-invoices`
- `sales`
- `dispatches`
- `customer-receipts`
- `supplier-payments`
- `cash-bank-expenses`
- `labour-payments`
- `bag-purchases`

### List

`GET /v1/transactions/{route}?branchId=BR-001&search=&page=1&pageSize=30`

```json
{
  "items": [
    {
      "id": "PI-0448",
      "type": "purchaseInvoice",
      "party": "Lakshmi Traders",
      "date": "2026-07-30T08:30:00.000Z",
      "status": "Approved",
      "amount": 74500,
      "summary": "Tonnage • 2.5 t",
      "branchId": "BR-001",
      "syncPending": false
    }
  ],
  "page": 1,
  "pageSize": 30,
  "total": 1
}
```

### Create

`POST /v1/transactions/{route}`

```http
X-Idempotency-Key: <uuid>
```

```json
{
  "type": "purchaseInvoice",
  "branchId": "BR-001",
  "values": {
    "supplier": "Lakshmi Traders",
    "warehouse": "Main Yard",
    "quantityMode": "Lessing · Ton wise",
    "quantity": "1200",
    "discount": "30",
    "actualQuantity": "840",
    "purchaseRate": "28"
  },
  "clientCreatedAt": "2026-07-30T08:30:00.000Z"
}
```

The response is one transaction record. Repeated idempotency keys must not
create duplicate business transactions.

Quantity rules currently reflected in the client:

- Ton-wise discount is per 100 kg, maximum 50 kg; notify above 30 kg.
- Piece-wise discount is per 1,000 pieces, maximum 100 pieces; notify above 20.
- The backend remains authoritative and returns field errors when configuration
  or approval limits differ by company/branch.

### Validation error

HTTP 400/409/422:

```json
{
  "message": "Please correct the highlighted fields.",
  "fieldErrors": {
    "discount": "Manager approval is required."
  }
}
```

## Reports

Route values:

- `purchase-register`
- `sales-register`
- `supplier-statement`
- `customer-statement`
- `labour-attendance`
- `pending-dispatch`
- `outstanding`
- `profit-loss`

### Fetch report

`GET /v1/reports/{route}?branchId=BR-001&range=last90Days&partyId=CUS-001`

```json
{
  "type": "customerStatement",
  "summary": "₹2,84,500",
  "subtitle": "Customer balance",
  "parties": ["Green Mart", "Anand Stores"],
  "metrics": {},
  "rows": [
    {
      "primary": "24 Jul",
      "secondary": "DS-0821",
      "tertiary": "Sale",
      "value": "₹32,400",
      "credit": false
    }
  ]
}
```

P&L uses `metrics` and may return an empty `rows` list.

### Export

`POST /v1/reports/{route}/exports`

```json
{
  "branchId": "BR-001",
  "range": "last90Days",
  "partyId": "CUS-001"
}
```

```json
{ "downloadUrl": "https://files.example.com/signed/report.pdf" }
```

The URL should be short-lived and HTTPS.

## Error policy

- `401/403`: token refresh once; expire the session if refresh fails.
- `400/409/422`: typed validation error, optionally with field errors.
- Connection/timeout: cached reads and encrypted queued writes.
- Other status codes: safe generic UI message; diagnostic correlation ID may be
  logged without business payloads.
