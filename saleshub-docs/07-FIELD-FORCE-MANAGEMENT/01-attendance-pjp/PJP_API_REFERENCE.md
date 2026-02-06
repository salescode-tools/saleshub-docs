# 📄 PJP (Permanent Journey Plan) API Reference

This document provides the technical specification for the PJP management APIs. The PJP system uses a **6-week flattened schedule** to define recurring visit patterns for sales representatives.

---

## 🚀 Overview

The PJP API allows you to manage the master schedule for field visits. 
- **Flattened Schedule**: Instead of complex logic, we use six explicit week arrays (`week1` to `week6`).
- **Day Codes**: Standardized 3-letter codes: `MON`, `TUE`, `WED`, `THU`, `FRI`, `SAT`, `SUN`.
- **Tenant Isolation**: All requests require the `X-Tenant-Id` header.

---

## 🛠️ Authentication & Headers

Standard headers required for all requests:

| Header | Value | Description |
|--------|-------|-------------|
| `Content-Type` | `application/json` | Request/Response format |
| `Authorization` | `Bearer <JWT_TOKEN>` | Standard JWT token |
| `X-Tenant-Id` | `<TENANT_ID>` | Target tenant identifier |

---

## 📍 Endpoints

### 1. Create / Upsert PJP Master
Creates a new PJP record or updates an existing one for a salesrep/beat combination.

**Method:** `POST`  
**Path:** `/pjp`

#### Request Body
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `salesrep` | String | ✅ | Username of the sales representative |
| `beatCode` | String | ✅ | Unique code for the beat |
| `routeCode` | String | ❌ | Optional route code |
| `frequency` | String | ✅ | Typically `MONTHLY` for flattened weeks |
| `week1` | Array<String> | ✅ | Days of visit in Week 1 (e.g., `["MON", "TUE"]`) |
| `week2` | Array<String> | ✅ | Days of visit in Week 2 |
| `week3` | Array<String> | ✅ | Days of visit in Week 3 |
| `week4` | Array<String> | ✅ | Days of visit in Week 4 |
| `week5` | Array<String> | ✅ | Days of visit in Week 5 |
| `week6` | Array<String> | ✅ | Days of visit in Week 6 |
| `active` | Boolean | ✅ | Activation status |
| `outlets` | Array<Object> | ❌ | List of outlets to map immediately |

**Outlet Object Structure:**
- `outletCode` (String, Required)
- `sequenceNo` (Integer, Required)

#### Response (200 OK)
Returns the created `PjpMaster` object with its generated `id`.

```json
{
  "id": 123,
  "salesrep": "sr_amit",
  "beatCode": "BEAT_NORTH",
  "frequency": "MONTHLY",
  "week1": ["MON"],
  "week2": ["MON"],
  "week3": ["MON"],
  "week4": ["MON"],
  "week5": ["MON"],
  "week6": ["MON"],
  "active": true
}
```

---

### 2. List PJPs
Retrieve PJP records with optional filtering.

**Method:** `GET`  
**Path:** `/pjp`

#### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `salesrepUsername` | String | ❌ | Filter by salesrep |
| `beatCode` | String | ❌ | Filter by beat |
| `routeCode` | String | ❌ | Filter by route |
| `limit` | Integer | ❌ | Max results (default 50) |
| `offset` | Integer | ❌ | Pagination offset |

#### Response (200 OK)
Array of `PjpMaster` objects.

---

### 3. Get PJP Outlets
Fetch the list of stores mapped to a specific PJP.

**Method:** `GET`  
**Path:** `/pjp/{id}/outlets`

#### Response (200 OK)
```json
[
  {
    "outletCode": "OUT_001",
    "sequenceNo": 1
  },
  {
    "outletCode": "OUT_002",
    "sequenceNo": 2
  }
]
```

---

### 4. Update PJP Outlets (Bulk)
Replaces the entire list of outlets for a PJP.

**Method:** `PUT`  
**Path:** `/pjp/{id}/outlets`

#### Request Body
Array of outlet mappings.
```json
[
  { "outletCode": "OUT_001", "sequenceNo": 1 },
  { "outletCode": "OUT_003", "sequenceNo": 2 }
]
```

#### Response (200 OK)
```json
{ "status": "ok" }
```

---

### 5. Get Unique Beats & Routes
Returns unique codes for dropdowns/filters.

**Method:** `GET`  
**Path:** `/pjp/unique-values`

#### Query Parameters
- `salesrepUsername` (optional)

#### Response (200 OK)
```json
{
  "beats": ["BEAT_A", "BEAT_B"],
  "routes": ["ROUTE_1", "ROUTE_2"]
}
```

---

## 💡 Implementation Examples

### 1. Every Week "Monday" Pattern (Weekly Proxy)
To simulate a weekly visit every Monday:
```json
{
  "salesrep": "alex",
  "beatCode": "MON_ROUTE",
  "frequency": "MONTHLY",
  "week1": ["MON"], "week2": ["MON"], "week3": ["MON"], 
  "week4": ["MON"], "week5": ["MON"], "week6": ["MON"],
  "active": true
}
```

### 2. Alternate Weeks (Bi-Weekly Proxy)
To visit every 1st and 3rd week Tuesday:
```json
{
  "week1": ["TUE"],
  "week2": [],
  "week3": ["TUE"],
  "week4": [],
  "week5": [],
  "week6": []
}
```

---

## ⚠️ Notes
- If an outlet is uploaded via MDM with different days in different weeks, the system will now correctly group them into a single PJP record with the flattened `week1-6` arrays populated.
- **Visit Plan Generation**: The generator looks at the target date, finds which week of the month it is (1-6), and checks the corresponding array for the current day of the week.
