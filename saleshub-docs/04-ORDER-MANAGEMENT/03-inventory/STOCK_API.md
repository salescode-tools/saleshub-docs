# Stock Management API Documentation

The Stock Management API allows for tracking and updating product inventory levels across different scopes (Distributors, Outlets, etc.). It supports both absolute replacements and relative additions (increments) of stock quantities.

---

## 1. Concepts

### Stock Scopes
Stock is tracked within a specific "scope". Common scopes include:
- `DISTRIBUTOR`: Stock held by a distributor.
- `OUTLET`: Stock available at a specific outlet.
- `COMPANY`: Overall company-level stock.

### Update Modes
When updating stock, the `updateMode` determines how the values are handled in the database:
- `REPLACE`: (Default) The existing stock quantities are overwritten with the new values.
- `ADD`: The new values are added to the existing quantities (used for replenishment or stock-in).

---

## 2. API Endpoints

### List Stocks
Retrieve stock records with optional filtering.

- **Endpoint:** `GET /stocks`
- **Authentication:** Required
- **Query Parameters:**
  - `sku` (String, Optional): Filter by product SKU.
  - `scope` (String, Optional): Filter by stock scope (e.g., `DISTRIBUTOR`, `OUTLET`).
  - `ownerId` (String, Optional): Filter by the identifier of the scope owner (e.g., Distributor Code).
  - `updateMode` (String, Optional): Filter records by their last update mode.

### Upsert Stock
Update or create a stock record for a specific SKU, Scope, and Owner.

- **Endpoint:** `POST /stocks`
- **Authentication:** Required
- **Request Body (Stock):**
```json
{
  "productSku": "SKU_001",
  "scope": "DISTRIBUTOR",
  "ownerId": "DIST_A",
  "qtyCases": 10,
  "qtyPieces": 5,
  "qtyUnits": 105,
  "updateMode": "ADD"
}
```
> **Note:** `qtyUnits` is typically the base unit (e.g., `qtyCases * unitsPerCase + qtyPieces`). The specific calculation logic depends on product configuration.

---

## 3. MDM Ingestion (CSV)

Stock data can be bulk-uploaded via the standard MDM multipart endpoint.

- **MDM Entity Type**: `STOCK`
- **Endpoint**: `POST /master/upload/multipart`
- **Canonical Headers**: `skucode`, `scope`, `owner_id`, `qty_cases`, `qty_pieces`, `qty_units`, `mode`

**Example CSV:**
```csv
skucode,scope,owner_id,qty_cases,qty_pieces,qty_units,mode
SKU_P001,DISTRIBUTOR,DIST001,5,0,50,ADD
SKU_P002,OUTLET,OUT_ABC,0,10,10,REPLACE
```

---

## 4. Data Structures

### Stock Schema
- `productSku`: The unique identifier for the product (String).
- `scope`: The context of the stock (e.g., `DISTRIBUTOR`, `OUTLET`).
- `ownerId`: The ID of the owner for the given scope (e.g., Distributor Code).
- `qtyCases`: Quantity in cases (Decimal).
- `qtyPieces`: Quantity in individual pieces (Decimal).
- `qtyUnits`: Total equivalent quantity in base units (Decimal).
- `updateMode`: `ADD` or `REPLACE` (String).
- `updatedAt`: Timestamp of the last update (ISO8601).
- `extendedAttr`: Custom metadata map (JSON Object).
