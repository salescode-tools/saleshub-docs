# Order Promotion Audit Analytics API

The Order Promo Audit Analytics API provides high-level summaries and entity-specific performance breakdowns for applied promotions. This enables rapid analysis of discount distribution across orders, outlets, salesreps, and distributors.

---

## 🏗️ Analytics Architecture

The analytics engine queries the `order_promo_audit` table to provide real-time aggregates. It supports the same filtering capabilities as the list API, allowing users to drill down into specific promotions or timeframes.

---

## 🚀 API Endpoints

### 1. Get Audit Summary
Retrieve aggregate metrics for promotions.

- **Endpoint**: `GET /order-promo-audit/summary`
- **Auth Required**: ✅

#### Query Parameters:
| Parameter | Type | Description |
| :--- | :--- | :--- |
| `orderId` | Long | Filter summary by a specific order ID. |
| `promoId` | Long | Filter summary by a specific promotion ID. |
| `outletCode` | String | Analyze promotions for a specific outlet. |
| `distributorCode`| String | Analyze promotions for a specific distributor. |
| `salesrep` | String | Analyze promotions managed by a specific salesrep. |

**Success Response (200 OK):**
```json
{
  "totalDiscount": 1550.50,
  "totalOrders": 45,
  "totalOutlets": 12,
  "totalDistributors": 3,
  "totalSalesreps": 8
}
```

---

### 2. Get Top-N Breakdown
Retrieve ranked lists of top performers based on discount value.

- **Endpoint**: `GET /order-promo-audit/top-n`
- **Auth Required**: ✅

#### Query Parameters:
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `n` | Integer | `5` | Number of items to return in each category. |
| `promoId` | Long | `null` | Analyze top performers for a specific promotion. |
| `outletCode` | String | `null` | Filter the ranking within a specific outlet. |
| `distributorCode`| String | `null` | Filter the ranking within a specific distributor. |
| `salesrep` | String | `null` | Filter the ranking within a specific salesrep. |

**Success Response (200 OK):**
```json
{
  "outlets": [
    { "code": "OTL_101", "name": "Super Daily Mart", "totalDiscount": 850.25, "orderCount": 12 },
    ...
  ],
  "salesreps": [
    { "code": "john_doe", "name": "John Doe", "totalDiscount": 2450.00, "orderCount": 35 },
    ...
  ],
  "distributors": [
    { "code": "DIST_NORTH", "name": "North Distributors Ltd", "totalDiscount": 5600.00, "orderCount": 82 },
    ...
  ],
  "locations": [
    { "code": "LOC_Z1", "name": "Zone 1 Central", "totalDiscount": 4200.50, "orderCount": 64 },
    ...
  ]
}
```

---

## 📊 Analyzed Entities

### 🏬 Outlets
Ranked by total discount value received across all eligible orders.

### 👤 Sales Representatives
Ranked by total discount value generated in their coverage area. Includes full names for easy identification.

### 🚚 Distributors
Ranked by total discount value processed through their fulfillment center.

### 📍 Locations
Ranked by total discount value distributed within a geographical boundary.
- **Mapping**: Based on the `org_location_mapping` (type: `OUTLET`) linking outlets to their hierarchical locations.

---

## 💡 Use Cases

1. **ROI Analysis**: Determine which promotions are consuming the most discount budget.
2. **Salesrep Performance**: Identify salesresps who are most effective at utilizing promotional schemes to drive orders.
3. **Geographical Insights**: See how promotions are performing in different zones/regions.
4. **Distribution Monitoring**: Track which distributors are processing the highest volume of promotional orders.
