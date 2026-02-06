# Retailer Mapping API Documentation

The Retailer Mapping API manages the relationships between **Outlets**, **Distributors**, and **Sales Representatives**. These mappings define which SalesRep serves which Outlet and through which Distributor.

## 1. Data Model (`RetailerMap`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | Long | Unique mapping ID (auto-generated). |
| `outletCode` | String | Unique code of the Outlet (**Required**). |
| `distributorCode` | String | Code of the associated Distributor. |
| `salesrepCode` | String | Username of the associated Sales Representative. |
| `active` | Boolean | Whether this mapping is active (default: `true`). |
| `extendedAttr` | JSON | Flexible attributes for the mapping (e.g., `beat`, `route`). |
| `createdAt` | Timestamp | Creation timestamp. |

---

## 2. API Endpoints

### 2.1 List Mappings

Retrieves existing retailer mappings with optional filters.

- **Endpoint**: `GET /retailer-maps`
- **Query Params**:
    - `q`: (Optional) General search across outlet, distributor, and salesrep codes.
    - `outletCode`: (Optional) Filter by specific outlet.
    - `distributorCode`: (Optional) Filter by specific distributor.
    - `salesrepCode`: (Optional) Filter by specific salesrep.
    - `active`: (Optional) Filter by active status.
    - `limit`: (Optional) Results per page (default: 25).
    - `offset`: (Optional) Pagination offset (default: 0).
- **Response**: `Page<RetailerMap>`

### 2.2 Create Mapping (Single)

Creates a single outlet association.

- **Endpoint**: `POST /retailer-maps`
- **Body**: `RetailerMap`

### 2.3 Bulk Create Mappings

Creates multiple mappings in one request.

- **Endpoint**: `POST /retailer-maps/bulk`
- **Body**:
  ```json
  {
    "items": [
      { "outletCode": "OUT001", "distributorCode": "DIST01" },
      { "outletCode": "OUT001", "salesrepCode": "SR_ALICE" }
    ]
  }
  ```

### 2.4 Sync Mappings (Full Replace)

Synchronizes mappings for specific outlets. **This will delete any existing mappings for the outlets included in the request and replace them with the provided list.**

- **Endpoint**: `POST /retailer-maps/sync`
- **Body**: Same as Bulk Create.
- **Logic**:
  1. Identifies all unique `outletCode`s in the request.
  2. Deletes all current records for those outlets.
  3. Inserts the new provided mappings.

#### Example: Sync Outlets
`POST /retailer-maps/sync`
```json
{
  "items": [
    { "outletCode": "OUT001", "distributorCode": "NEW_DIST" }
  ]
}
```
*(Result: All previous mappings for OUT001 are removed; only NEW_DIST remains associated.)*

### 2.5 Update Mapping (by ID)

Updates an existing mapping record.

- **Endpoint**: `PUT /retailer-maps/{id}`
- **Path Params**: `id` (Long)

### 2.6 Delete Mapping (by ID)

Removes a specific mapping record.

- **Endpoint**: `DELETE /retailer-maps/{id}`
- **Path Params**: `id` (Long)

---

## 3. Usage Notes
- Mappings are tenant-scoped.
- The `ON CONFLICT` logic in non-sync endpoints prevents duplicate (Tenant + Outlet + Dist + SR) entries.
- Use the **Sync** endpoint for full "Full Refresh" integration scenarios.
