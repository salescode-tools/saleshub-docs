# Order API Documentation

The Order API provides endpoints to manage sales orders, including creation, status tracking, and line item management.

---

## 1. List Orders
Retrieve a list of orders with filtering and pagination.

- **Endpoint:** `GET /orders`
- **Authentication:** Required
- **Query Parameters:**
  - `q` (String, Optional): Search by outlet name, code, channel, or tags.
  - `status` (Integer, Optional): Filter by order status code. Supports multiple values (e.g., `status=1&status=2`).
  - `outlet` (String, Optional): Filter by specific outlet code.
  - `username` (String, Optional): Filter by sales representative username.
  - `distributor` (String, Optional): Filter by distributor code.
  - `source` (String, Optional): Filter by order source (e.g., `PWA`, `MOBILE`). Supports multiple values (e.g., `source=PWA&source=MOBILE`).
  - `orderType` (String, Optional): Filter by order type (e.g., `SFA`, `eB2B`). Supports multiple values (e.g., `orderType=SFA&orderType=eB2B`).
  - `from` (ISO8601 String, Optional): Filter orders created after this timestamp.
  - `to` (ISO8601 String, Optional): Filter orders created before this timestamp.
  - `sortBy` (String, Optional): Field to sort by. Supported values: `date` (default), `amount`, `quantity`.
  - `sortDir` (String, Default: `DESC`): Sort direction. Supported values: `ASC`, `DESC`.
  - `limit` (Integer, Default: 50): Number of records to return.
  - `offset` (Integer, Default: 0): Number of records to skip.
  - `hierarchical` (Boolean, Default: `true`): If `true`, includes orders from child tenants.

---

## 2. Export Orders
Download filtered order data in Excel (.xlsx) format.

- **Endpoint:** `GET /orders/export`
- **Authentication:** Required
- **Query Parameters:** (Supports all filtering, sorting, and pagination parameters from "List Orders")
  - `id` (String, Optional): Specific order IDs to export. Supports multiple values (e.g., `id=123&id=456`).
  - `q` (String, Optional): Search by outlet name, code, channel, or tags.
  - `status` (Integer, Optional): Filter by order status code. Supports multiple values.
  - `outlet` (String, Optional): Filter by specific outlet code.
  - `username` (String, Optional): Filter by sales representative username.
  - `distributor` (String, Optional): Filter by distributor code.
  - `source` (String, Optional): Filter by order source. Supports multiple values.
  - `orderType` (String, Optional): Filter by order type. Supports multiple values.
  - `from` (ISO8601 String, Optional): Filter orders created after this timestamp.
  - `to` (ISO8601 String, Optional): Filter orders created before this timestamp.
  - `location` (String, Optional): Filter by location code (includes child locations).
  - `hierarchical` (Boolean, Default: `true`): If `true`, includes orders from child tenants.
  - `sortBy` (String, Optional): Field to sort by. Supported values: `date` (default), `amount`, `quantity`, `orderNumber`.
  - `sortDir` (String, Default: `DESC`): Sort direction. Supported values: `ASC`, `DESC`.
  - `limit` (Integer, Default: `10000`): Maximum number of order lines to export.
  - `offset` (Integer, Default: `0`): Number of order lines to skip.
- **Response:** Binary stream of an Excel file named `orders_export.xlsx`.
- **Excel Structure:**
  - Each row represents an order line item (orders with multiple lines will have multiple rows).
  - **Columns:** User ID, Order Number, Order Status, Company Outlet Code, Outlet Name, Sales Rep ID, Sales Rep Name, Channel, SKU Code, SKU Desc, Category, Brand, QTY (Cs), QTY (Pc), QTY (Other), Price per piece, Amount, Discount, Taxable value, GST %, GST Amount, Final Amount.
- **Example Request:**
  ```
  GET /orders/export?status=1&status=2&sortBy=amount&sortDir=ASC&limit=5000
  ```

---

## 3. Get Unique Values
Retrieve unique values for `source` and `orderType` based on the authenticated user's organization context.

- **Endpoint:** `GET /orders/unique-values`
- **Authentication:** Required
- **Response Structure:**
```json
{
  "sources": ["PWA", "MOBILE"],
  "orderTypes": ["SFA", "eB2B"]
}
```
- **Behavior**: The returned values are filtered based on the current user's visibility (e.g., a Distributor will only see sources and types present in their own orders).

---

## 4. Get Order Summary
Retrieve calculated metrics for orders across the tenant.

- **Endpoint:** `GET /orders/summary`
- **Authentication:** Required
- **Response Fields:**
  - `totalOrders`: Total count of orders.
  - `pendingOrders`: Count of orders in DRAFT or SUBMITTED status.
  - `approvedOrders`: Count of orders in APPROVED status.
  - `totalOrderValue`: Aggregate `netAmount` of all orders.

---

## 5. Get Order Details
Retrieve specific order details, optionally expanding it to include line items.

- **Endpoint:** `GET /orders/{id}`
- **Authentication:** Required
- **Query Parameters:**
  - `expand` (String, Optional): Use `lines` or `all` to include the `lines` array in the response.

---

## 6. Create Order
Place a new order. The system calculates pricing rules and applies eligible promotions automatically.

- **Endpoint:** `POST /orders`
- **Authentication:** Required
- **Query Parameters:**
  - `dryRun` (Boolean, Optional): If `true`, returns the simulated order calculation (including applied promotions and calculated prices) without saving to the database.
  - `delivery` (Boolean, Optional): If `true`, the system calculates the predicted `deliveryDate` based on the outlet's hierarchical delivery configurations.
- **Request Body (CreateOrderRequest):**
```json
{
  "orderNumber": "ORD-12345", 
  "referenceNumber": "REF-ABC-001",
  "outletCode": "OUT_001",
  "distributor": "DIST_001",
  "notes": "Delivery after 5 PM",
  "extendedAttr": {
    "orderLevelKey": "someValue",
    "deliveryPrefs": { "gate": 5 }
  },
  "lines": [
    {
      "sku": "SKU_P001",
      "qtyCases": 2,
      "qtyPieces": 10,
      "uom": "UNIT",
      "distributor": "DIST_001",
      "extendedAttr": {
        "lineNote": "Fragile",
        "nestedData": { "shelf": "A1" }
      }
    }
  ]
}
```
> **Note:** `salesrep` is automatically filled from the authenticated user's context if they have the `MEMBER` or `ORG_MEMBER` role.

### Custom UoM Ordering

Products can be ordered using custom units of measure (BOX, TRAY, PALLET, etc.) if they have been defined via the Product UoM Conversion API.

#### Example: Order with Custom UoM
```json
{
  "outletCode": "OUT_001",
  "distributor": "DIST_001",
  "lines": [
    {
      "sku": "RICE_25KG",
      "uom": "BOX",
      "qty": 5.0,           // 5 boxes
      "unitPrice": 500.0
    },
    {
      "sku": "OIL_5L",
      "uom": "PALLET",
      "qty": 2.5,           // 2.5 pallets
      "unitPrice": 12000.0
    }
  ]
}
```

**System Behavior**:
- The system looks up the conversion factor for each custom UoM (e.g., BOX = 12 pieces)
- Calculates `lineUnits = qty × conversionFactor`
- For example: 5 BOX × 12 = 60 pieces
- The `qty` value is stored in `extendedAttr` for reference

#### Legacy Format (Still Supported)

The traditional format using `qtyCases` and `qtyPieces` continues to work:

```json
{
  "outletCode": "OUT_001",
  "distributor": "DIST_001",
  "lines": [
    {
      "sku": "SKU_P001",
      "uom": "CASE",
      "qtyCases": 3.0,
      "qtyPieces": 5.0
    }
  ]
}
```

**Note**: You can mix custom UoM lines and legacy format lines in the same order.

---

## 7. Update Order
Update top-level fields of an existing order.

- **Endpoint:** `PUT /orders/{id}`
- **Request Body (UpdateOrderRequest):**
```json
{
  "distributorCode": "DIST_NEW",
  "notes": "Updated delivery instructions",
  "salesrep": "SR_002",
  "outletCode": "OUT_001"
}
```

---

## 8. Change Order Status
Transition an order through its lifecycle.

- **Endpoint:** `POST /orders/{id}/status`
- **Request Body (ChangeStatusRequest):**
```json
{
  "statusCode": 1,
  "reason": "Customer confirmed order"
}
```
**Standard Status Codes:**
- `0`: DRAFT
- `1`: SUBMITTED
- `2`: APPROVED
- `3`: REJECTED
- `4`: CANCELLED
- `5`: FULFILLED

---

## 9. Order Line Item Management

### Add Line Item
- **Endpoint:** `POST /orders/{id}/lines`
- **Request Body:** `OrderLineUpsertRequest` (See fields below)

### Update Line Item
- **Endpoint:** `PUT /orders/{id}/lines/{lineId}`
- **Request Body:** `OrderLineUpsertRequest`

### Delete Line Item
- **Endpoint:** `DELETE /orders/{id}/lines/{lineId}`

---

## 10. Retailer Orders (Self-Ordering)

The system supports a **Retailer-First** ordering flow where a retailer can log in and place orders directly for their own outlet.

### Process Flow
1. **Association**: The authenticated user must have the `RETAILER` role and be associated with one or more Outlets.
2. **Mapping**: The Outlet must be mapped to a Distributor (via Admin/MDM setup).
3. **Ordering**: The retailer places an order using their specific `outletCode`.

### Example Request (Retailer Token)
- **Endpoint:** `POST /orders`
- **Authentication:** Retailer User Token Required
- **Body:**
```json
{
  "outletCode": "OUT_RETAIL_001",
  "referenceNumber": "APP_REF_123",
  "distributor": "DIST_MAPPED_001",
  "notes": "Weekly inventory restock",
  "lines": [
    {
      "sku": "SKU_P001",
      "uom": "UNIT",
      "qtyPieces": 20
    }
  ]
}
```

### Context Awareness
- **Validation**: When a retailer places an order, the system validates that the `outletCode` actually belongs to the user.
- **Auto-Fill**: The `salesrep` field is typically left null for retailer self-orders or mapped to a "Web/Self-Order" system user.
- **Promotions**: All retailer-applicable promotions (targeted by Channel, Segment, or direct Target Group) are applied automatically just as in a Salesrep-led order.

---

## 11. Order Splitting by Distributor

When a single order request contains items belonging to multiple distributors, the system automatically splits the request into multiple distinct order records.

### Logic & Behavior
- **Trigger**: Splitting occurs if at least two lines in the `lines` array have different `distributor` codes.
- **Group ID**: All orders resulting from a single split operation share a common `groupId`.
  - The `groupId` is set to the `id` of the first order created in the batch.
- **Promotion Application**: Order-level promotions are calculated based on the *entire* request before splitting but are typically attached to the primary (first) order record in the group.
- **Amounts**: Each split order maintains its own `grossAmount`, `discount`, and `netAmount` based specifically on its lines.

### Example Response (Multi-Distributor Order)
When an order is split, the API returns the primary order and a list of all part-orders.

```json
{
  "order": {
    "id": "1001",
    "groupId": "1001",
    "distributor": "DIST_A",
    "netAmount": 500.0,
    ...
  },
  "splittedOrders": [
    {
      "id": "1001",
      "groupId": "1001",
      "distributor": "DIST_A",
      "netAmount": 500.0
    },
    {
      "id": "1002",
      "groupId": "1001",
      "distributor": "DIST_B",
      "netAmount": 300.0
    }
  ]
}
```

---

## Data Structures

### Order Schema (Response)
- `id`: Unique identifier (String)
- `groupId`: Shared identifier for orders that were part of a split request (String)
- `orderNumber`: Human-readable order reference
- `referenceNumber`: Unique external reference to avoid duplications (optional)

- `outlet`: Outlet code
- `salesrep`: Sales Representative username
- `distributor`: Distributor code
- `statusCode`: Current status (0-5)
- `grossAmount`: Total amount before discounts
- `discount`: Total discount applied (Promotions + Price Rules)
- `taxAmount`: Total tax calculated for the order.
- `netAmount`: Final payable amount (Gross - Discount + Tax)
- `taxInfo`: JSON object containing component-level tax breakdown (CGST, SGST, etc.)
- `lines`: Array of `OrderLine` objects (if expanded)
- `appliedPromotions`: List of promotion details applied to the total order.
- `extendedAttr`: Custom key-value map (JSON Object) for arbitrary metadata.
- `deliveryDate`: Predicted date of delivery (ISO String `YYYY-MM-DD`).

### OrderLine Schema
- `sku`: Product SKU
- `uom`: Unit of measure (UNIT, CASE, PIECE, or custom UoM like BOX, TRAY)
- `qty`: Quantity in the specified custom UoM (used with custom UoMs)
- `qtyCases`: Quantity in cases (legacy format)
- `qtyPieces`: Quantity in individual units (legacy format)
- `lineUnits`: Total quantity in base units (automatically calculated from qty × conversionFactor or qtyCases + qtyPieces)
- `unitPrice`: Calculated price per unit
- `lineAmount`: Total gross line amount (`unitPrice` * `lineUnits`)
- `discount`: Total line discount
- `taxAmount`: Tax calculated for this line
- `netAmount`: Final line total (`lineAmount` - `discount` + `taxAmount`)
- `taxInfo`: Specific tax rates and components for this SKU
- `isFree`: Boolean indicating if this is a free-good item from a promotion.
- `priceRuleId`: Reference to the price rule applied.
- `priceUomUsed`: The UoM used for pricing (UNIT, CASE, PIECE, or custom UoM)
- `appliedPromotions`: Promotions specifically impacting this line item.
- `extendedAttr`: Custom key-value map (JSON Object) for arbitrary line-level metadata.

---

## 12. Tax & Promotion Integration (The Complete Picture)

The system computes taxes **after** all eligible promotions and price rules have been applied. This ensures tax is only calculated on the actual taxable value.

### Order Calculation Flow:
1. **Gross**: Base Price * Qty
2. **Promotions**: Deduct applicable discounts (e.g., 10% off).
3. **Taxable Base**: Gross - Discount
4. **Tax**: Calculate tax Level (e.g., 18%) on the Taxable Base.
5. **Net Amount**: Taxable Base + Tax

### Example Response (Promo + Tax together):
```json
{
  "order": {
    "orderNumber": "ORD-TAX-PROMO-EXAMPLE",
    "grossAmount": 2000.0,
    "discount": 200.0,
    "taxAmount": 324.0,
    "netAmount": 2124.0,
    "taxInfo": {
      "total_tax": 324.0,
      "components": {
        "cgst": { "value": 162.0 },
        "sgst": { "value": 162.0 }
      }
    },
    "lines": [
      {
        "sku": "SKU_001",
        "qtyPieces": 2.0,
        "unitPrice": 1000.0,
        "lineAmount": 2000.0,
        "discount": 200.0,
        "taxAmount": 324.0,
        "netAmount": 2124.0,
        "taxInfo": {
          "rate": 18.0,
          "tax_name": "GST 18%",
          "taxable_amount": 1800.0,
          "components": {
            "cgst": { "percent": 9.0, "value": 162.0 },
            "sgst": { "percent": 9.0, "value": 162.0 }
          }
        },
        "appliedPromotions": [
          {
             "promotionName": "Flat 10% Off",
             "discountAmount": 200.0
          }
        ]
      }
    ]
  }
}
```
