# Delivery Configuration API Guide

The Delivery Configuration system manages recurring delivery schedules using a 6-week cyclical pattern. It supports hierarchical overrides and is used to predict delivery dates during order placement.

---

## 1. Concepts

### Hierarchical Resolution
When calculating a delivery date, the system looks for configurations in the following priority:
1. **OUTLET**: Specific to a single outlet code.
2. **OUTLET_TAG**: Applies to all outlets sharing a specific tag (e.g., "RURAL").
3. **DISTRIBUTOR**: Default for all outlets served by a specific distributor.
4. **SALESREP**: Default for all outlets assigned to a specific sales representative.
5. **COMPANY**: Global system default (Level: `COMPANY`, LevelId: `DEFAULT`).

### 6-Week Cycle
Schedules are defined as a comma-separated list of days (e.g., "Monday, Wednesday") for each of the 6 weeks in the cycle.
- **Epoch**: The cycle started on **Monday, January 1, 2024** (Week 1).
- **Week Calculation**: `((Weeks since Epoch) % 6) + 1`.

---

## 2. API Endpoints

### List All Configurations
- **Endpoint:** `GET /delivery-config`
- **Query Parameters:**
  - `hierarchical` (Boolean, Default: `false`): If `true`, includes configurations from all child tenants associated with the authenticated user's tenant.
- **Response:** Array of `DeliveryConfig` objects.

### Bulk Upload Configurations
- **Endpoint:** `POST /delivery-config/bulk`
- **Body:** Array of `DeliveryConfig` objects.
```json
[
  {
    "level": "OUTLET",
    "levelId": "OUT_001",
    "week1": "Monday, Thursday",
    "week2": "Tuesday",
    ...
    "week6": "Wednesday"
  }
]
```

### Calculate Next Delivery Date
- **Endpoint:** `GET /delivery-config/next-date`
- **Query Parameters:**
  - `orderDate` (String, Optional): The base date for calculation (ISO `YYYY-MM-DD`). Defaults to today.
  - `outletCode` (String, Optional): The outlet code for hierarchical lookup.
  - `distributorCode` (String, Optional): The distributor code for fallback lookup.
  - `salesrepUsername` (String, Optional): The salesrep username for fallback lookup.
  - `leadTime` (Integer, Default: 0): Minimum days required before delivery can occur (added to the base `orderDate`).
  - `hierarchical` (Boolean, Default: `true`): 
    - If `false`: Only calculates the next date for the authenticated tenant.
    - If `true`: Iteratates through the current tenant and all child tenants, returning an array of next delivery dates (one per tenant) for the given criteria.
- **Response:** Object containing an array of `TenantNextDate` objects.
```json
{
  "results": [
    {
      "tenantId": "tenant1",
      "nextDeliveryDate": "2024-01-03"
    }
  ]
}
```

---

## 3. MDM Ingestion (CSV)

Delivery configurations can be bulk-uploaded via the standard MDM multipart endpoint.

- **MDM Entity Type**: `DELIVERY_CONFIG`
- **Endpoint**: `POST /master/upload/multipart`
- **Canonical Headers**: `level`, `level_id`, `week1`, `week2`, `week3`, `week4`, `week5`, `week6`

### Automatic Level Inference
If `level` or `level_id` are missing, the system infers them from these columns:
- `outletcode` -> Level: `OUTLET`
- `tag_name` -> Level: `OUTLET_TAG`
- `distributor_code` -> Level: `DISTRIBUTOR`
- `salesrep_code` -> Level: `SALESREP`

**Example CSV:**
```csv
outletcode,week1,week2,week3,week4,week5,week6
OUT_001,"Monday, Friday",Monday,"Monday, Friday",Monday,"Monday, Friday",Friday
```
