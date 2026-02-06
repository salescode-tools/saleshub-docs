# PJP and Visit Management API Documentation

## Overview
This document provides comprehensive API documentation for the PJP (Permanent Journey Plan) and Visit Management system in Sales Lite. The system enables sales teams to plan and track field visits to outlets.

## Table of Contents
1. [Beat Management APIs](#beat-management-apis)
2. [PJP Management APIs](#pjp-management-apis)
3. [Visit Plan APIs](#visit-plan-apis)
4. Visit Status API
5. [Attendance APIs](#attendance-apis)
6. Visit Log APIs
7. Data Models
8. Examples

---

## Beat Management APIs

### 1. Create Beat
Create a new beat (sales territory/route).

**Endpoint:** `POST /beats`

**Request Body:**
```json
{
  "code": "BEAT_001",
  "name": "Downtown Route",
  "territory": "North Zone",
  "active": true,
  "extendedAttr": {
    "region": "metro",
    "priority": "high"
  }
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "tenantId": "tenant123",
  "code": "BEAT_001",
  "name": "Downtown Route",
  "territory": "North Zone",
  "active": true,
  "extendedAttr": {
    "region": "metro",
    "priority": "high"
  },
  "createdAt": "2026-01-23T10:00:00Z"
}
```

---

### 2. List Beats
Retrieve a list of beats with optional search and pagination.

**Endpoint:** `GET /beats`

**Query Parameters:**
- `q` (optional): Search query for beat name or code
- `limit` (optional, default: 50): Maximum number of results
- `offset` (optional, default: 0): Pagination offset

**Example Request:**
```
GET /beats?q=downtown&limit=10&offset=0
```

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "code": "BEAT_001",
    "name": "Downtown Route",
    "territory": "North Zone",
    "active": true,
    "extendedAttr": {},
    "createdAt": "2026-01-23T10:00:00Z"
  }
]
```

---

## PJP Management APIs

### 1. Create PJP
Create a new Permanent Journey Plan with outlet mappings.

**Endpoint:** `POST /pjp`

**Request Body:**
```json
{
  "salesrep": "john.doe",
  "beatCode": "BEAT_001",
  "routeCode": null,
  "frequency": "MONTHLY",
  "week1": ["MON", "WED", "FRI"],
  "week2": ["MON", "WED", "FRI"],
  "week3": ["MON", "WED", "FRI"],
  "week4": ["MON", "WED", "FRI"],
  "week5": ["MON", "WED", "FRI"],
  "week6": ["MON", "WED", "FRI"],
  "active": true,
  "extendedAttr": {
    "notes": "Regular weekly visits"
  },
  "outlets": [
    {
      "outletCode": "OUT_001",
      "sequenceNo": 1,
      "latitude": 12.9716,
      "longitude": 77.5946
    }
  ]
}
```

**Note:** Either `beatCode` or `routeCode` (or both) can be provided.

**Weeks:** Data is organized into 6 explicit weeks (`week1` through `week6`). Each field is an array of 3-letter weekday codes.
- `SUN`, `MON`, `TUE`, `WED`, `THU`, `FRI`, `SAT`

**Frequency Logic:**
- If an outlet is visited every Monday, "MON" will be present in all weeks (`week1` to `week6`).
- If an outlet is visited only on the 1st Monday, "MON" will be present only in `week1`.

**Response:** `200 OK`
```json
{
  "id": 10,
  "tenantId": "tenant123",
  "salesrep": "john.doe",
  "beatCode": "BEAT_001",
  "frequency": "MONTHLY",
  "week1": ["MON", "WED", "FRI"],
  "week2": ["MON", "WED", "FRI"],
  "week3": ["MON", "WED", "FRI"],
  "week4": ["MON", "WED", "FRI"],
  "week5": ["MON", "WED", "FRI"],
  "week6": ["MON", "WED", "FRI"],
  "active": true,
  "extendedAttr": {
    "notes": "Regular weekly visits"
  },
  "createdAt": "2026-01-23T10:00:00Z"
}
```

---

### 2. List PJPs
Retrieve PJPs with optional filtering.

**Endpoint:** `GET /pjp`

**Query Parameters:**
- `salesrepUsername` (optional): Filter by salesrep username
- `beatCode` (optional): Filter by beat code
- `routeCode` (optional): Filter by route code
- `limit` (optional, default: 50): Maximum number of results
- `offset` (optional, default: 0): Pagination offset

**Example Request:**
```
GET /pjp?salesrepUsername=john.doe&limit=20
```

**Response:** `200 OK`
```json
[
  {
    "id": 10,
    "salesrep": "john.doe",
    "beatCode": "BEAT_001",
    "frequency": "MONTHLY",
    "week1": ["MON", "WED", "FRI"],
    "week2": ["MON", "WED", "FRI"],
    "week3": ["MON", "WED", "FRI"],
    "week4": ["MON", "WED", "FRI"],
    "week5": ["MON", "WED", "FRI"],
    "week6": ["MON", "WED", "FRI"],
    "active": true,
    "createdAt": "2026-01-23T10:00:00Z"
  }
]
```

---

### 3. Get PJP Outlets
Retrieve the list of outlets mapped to a PJP.

**Endpoint:** `GET /pjp/{pjpId}/outlets`

**Path Parameters:**
- `pjpId`: PJP ID

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "pjpId": 10,
    "outletCode": "OUT_001",
    "sequenceNo": 1,
    "latitude": 12.9716,
    "longitude": 77.5946,
    "extendedAttr": {},
    "createdAt": "2026-01-23T10:00:00Z"
  },
  {
    "id": 2,
    "pjpId": 10,
    "outletCode": "OUT_002",
    "sequenceNo": 2,
    "latitude": 12.9720,
    "longitude": 77.5950,
    "extendedAttr": {},
    "createdAt": "2026-01-23T10:00:00Z"
  }
]
```

---

### 4. Update PJP Outlets
Update the outlet mappings for a PJP (replaces existing mappings).

**Endpoint:** `PUT /pjp/{pjpId}/outlets`

**Path Parameters:**
- `pjpId`: PJP ID

**Request Body:**
```json
[
  {
    "outletCode": "OUT_001",
    "sequenceNo": 1
  },
  {
    "outletCode": "OUT_002",
    "sequenceNo": 2
  },
  {
    "outletCode": "OUT_003",
    "sequenceNo": 3
  }
]
```

**Response:** `200 OK`
```json
{
  "status": "ok"
}
```

---

### 5. Update PJP
Update PJP header and optionally outlets.

**Endpoint:** `PUT /pjp/{pjpId}`

**Path Parameters:**
- `pjpId`: PJP ID

**Request Body:**
```json
{
  "salesrep": "john.doe",
  "beatCode": "BEAT_001",
  "frequency": "MONTHLY",
  "week1": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "week2": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "week3": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "week4": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "week5": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "week6": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "active": true,
  "outlets": [
    {
      "outletCode": "OUT_001",
      "sequenceNo": 1
    }
  ]
}
```

**Response:** `200 OK`
```json
{
  "id": 10,
  "salesrep": "john.doe",
  "beatCode": "BEAT_001",
  "frequency": "MONTHLY",
  "active": true,
  "createdAt": "2026-01-23T10:00:00Z"
}
```

---

## Visit Plan APIs

### 1. Generate Visit Plan
Generate visit plans for a specific date based on active PJPs.

**Endpoint:** `POST /visit-plan/generate`

**Query Parameters:**
- `date` (optional, default: today): Date in `YYYY-MM-DD` format

**Example Request:**
```
POST /visit-plan/generate?date=2026-01-25
```

**Response:** `200 OK`
```json
{
  "inserted": 15
}
```

**Note:** This endpoint:
- Evaluates all active PJPs
- Evaluates all active PJPs
- Applies rules based on current week of the month (1-6) mapping to `week1`..`week6` columns
- Creates visit_plan records for matching outlets
- Skips duplicates (same date + salesrep + outlet)

### 1. Get Day Summary
Retrieve aggregate counts for salesrep activity (attendance and plans) for a specific day.

**Endpoint:** `GET /visit-plan/summary`

**Query Parameters:**
- `date` (optional, default: today): Date in `YYYY-MM-DD` format to get the summary for.
- `salesrepUsername` (optional): Further filter the summary for a specific salesrep.

**Security Logic:**
- **SALESREP**: Only sees their own summary (Total will be 1).
- **DISTRIBUTOR**: Sees aggregate summary for all salesreps mapped to them via `retailer_map`.
- **ADMIN/SYSTEM**: Sees global summary for the entire tenant, or filtered by `salesrepUsername`.

**Example Request:**
```
GET /visit-plan/summary?date=2026-02-03
```

**Response Body:**
- `totalSalesreps` (int): Total number of unique sales representatives included in the scope.
- `present` (int): Number of representatives marked as **Present** for the day.
- `absent` (int): Number of representatives marked as **Absent** for the day.
- `notMarked` (int): Number of representatives who have **not yet marked** attendance.
- `dayOff` (int): Number of representatives who have **no visit plans** generated for this date.

**Example Response:** `200 OK`
```json
{
  "totalSalesreps": 100,
  "present": 85,
  "absent": 5,
  "notMarked": 10,
  "dayOff": 15
}
```

---

### 2. List Visit Plans
Retrieve visit plans for a specific date with optional filtering.

**Endpoint:** `GET /visit-plan`

**Query Parameters:**
- `date` (optional, default: today): Date in `YYYY-MM-DD` format
- `salesrepUsername` (optional): Filter by salesrep
- `status` (optional): Filter by visit status (e.g., `PLANNED`, `COMPLETED`, `SKIPPED`)
- `attendanceStatus` (optional): Filter by rep's attendance (e.g., `Present`, `Absent`, `Not Marked`)

**Example Request:**
```
GET /visit-plan?date=2026-02-03&attendanceStatus=Present
```

**Response:** `200 OK`
```json
[
  {
    "id": 100,
    "tenantId": "tenant123",
    "visitDate": "2026-01-25",
    "salesrepUsername": "john.doe",
    "outletCode": "OUT_001",
    "plannedSequence": 1,
    "status": "PLANNED",
    "extendedAttr": {},
    "createdAt": "2026-01-23T10:00:00Z"
  },
  {
    "id": 101,
    "tenantId": "tenant123",
    "visitDate": "2026-01-25",
    "salesrepUsername": "john.doe",
    "outletCode": "OUT_002",
    "plannedSequence": 2,
    "status": "PLANNED",
    "extendedAttr": {},
    "createdAt": "2026-01-23T10:00:00Z"
  }
]
```

**Status Values:**
- `PLANNED`: Visit is scheduled
- `COMPLETED`: Visit has been completed
- `SKIPPED`: Visit was skipped
- `CANCELLED`: Visit was cancelled

---

## Visit Status API

### 1. Get Visit Summary Status
Retrieve a summary of the salesrep's performance and status for a specific day. This API combines attendance, PJP, and actual visits logged.

**Endpoint:** `GET /visit-status` (also available as `GET /visit-plan/visit-status` for backward compatibility)

**Query Parameters:**
- `salesrep` (required): Username of the sales representative
- `date` (optional, default: today): Date in `YYYY-MM-DD` format

**Example Request:**
```
GET /visit-status?salesrep=john.doe&date=2026-02-02
```

**Response:** `200 OK`
```json
{
  "salesrepCode": "john.doe",
  "salesrepName": "John Doe",
  "assignedRoute": "Downtown Route",
  "numberOfOutlets": 15,
  "attendanceStatus": "Present",
  "pjpCompletionStatus": "In Progress"
}
```

**Response Fields:**
- `salesrepCode`: The representative's username
- `salesrepName`: Full name of the representative
- `assignedRoute`: Name of the Beat or Route assigned in today's PJP. (Route Name takes priority if both exist).
- `numberOfOutlets`: Total number of outlets planned for today's PJP.
- `attendanceStatus`: `Present`, `Absent`, or `Not Marked`.
- `pjpCompletionStatus`: `Complete` (if all planned outlets visited) or `In Progress`.

---

### 2. Get Unique Values
Retrieve supported unique values for visit and attendance states.

**Endpoint:** `GET /visit-status/unique-values`

**Response:** `200 OK`
```json
{
  "attendanceStatuses": ["Present", "Absent", "Not Marked"],
  "pjpCompletionStatuses": ["Complete", "In Progress", "Incomplete", "N/A"]
}
```

---

## Attendance APIs

### 1. Simple Mark Attendance
Mark attendance for a single salesrep.

**Endpoint:** `POST /attendance/mark-status`

**Query Parameters:**
- `salesrep` (optional): Username of the sales representative. Defaults to the logged-in user.
- `status` (optional, default: `Present`): `Present` or `Absent`.
- `date` (optional, default: today): Date in `YYYY-MM-DD` format.

**Notes:**
- If the logged-in user is a `SALESREP`, they can only mark their own attendance.
- Attendance cannot be marked for past dates.
- Attendance for today is locked after the cutoff time (default: 11:59 PM).

**Example Request:**
```
POST /attendance/mark-status?status=Present
```

**Response:** `200 OK`
```json
{
  "status": "ok",
  "salesrep": "john.doe",
  "date": "2026-02-02",
  "isPresent": true
}
```

---

### 2. Bulk Mark Attendance
Mark attendance for multiple sales representatives for a specific date.

**Endpoint:** `POST /attendance/mark`

**Query Parameters:**
- `date` (optional, default: today): Date in `YYYY-MM-DD` format.

**Request Body:**
```json
[
  {
    "salesrepCode": "john.doe",
    "attendanceStatus": "Present"
  },
  {
    "salesrepCode": "jane.doe",
    "attendanceStatus": "Absent"
  }
]
```

**Response:** `200 OK`
```json
{
  "status": "ok"
}
```

---

## Visit Log APIs

### 1. Create Visit Log
Log a visit to an outlet.

**Endpoint:** `POST /visits`

**Request Body:**
```json
{
  "planId": 100,
  "salesrepUsername": "john.doe",
  "outletCode": "OUT_001",
  "visitedAt": "2026-01-23T14:30:00+05:30",
  "lat": 12.9716,
  "lng": 77.5946,
  "visitType": "PLANNED",
  "remarks": "Order placed for 50 units",
  "extendedAttr": {
    "orderValue": 5000,
    "duration": 30,
    "productsDiscussed": ["PROD_001", "PROD_002"]
  }
}
```

**Field Descriptions:**
- `planId` (optional): Reference to visit_plan.id if this was a planned visit
- `salesrepUsername` (required): Username of the sales representative
- `outletCode` (required): Outlet code being visited
- `visitedAt` (required): Timestamp with timezone (ISO 8601 format)
- `lat` (optional): GPS latitude
- `lng` (optional): GPS longitude
- `visitType` (optional): Type of visit (PLANNED, UNPLANNED, EMERGENCY, etc.)
- `remarks` (optional): Free-text notes
- `extendedAttr` (optional): Additional custom data

**Response:** `200 OK`
```json
{
  "id": 500,
  "tenantId": "tenant123",
  "planId": 100,
  "salesrepUsername": "john.doe",
  "outletCode": "OUT_001",
  "visitedAt": "2026-01-23T14:30:00+05:30",
  "lat": 12.9716,
  "lng": 77.5946,
  "visitType": "PLANNED",
  "remarks": "Order placed for 50 units",
  "extendedAttr": {
    "orderValue": 5000,
    "duration": 30
  },
  "createdAt": "2026-01-23T14:30:00Z"
}
```

---

### 2. List Visit Logs
Retrieve visit logs with flexible filtering options.

**Endpoint:** `GET /visits`

**Query Parameters:**
- `date` (optional): Specific date in `YYYY-MM-DD` format
- `month` (optional): Entire month in `YYYY-MM` format
- `outletCode` (optional): Filter by outlet code
- `salesrepUsername` (optional): Filter by salesrep username
- `limit` (optional, default: 200): Maximum number of results
- `offset` (optional, default: 0): Pagination offset

**Note:** If both `date` and `month` are provided, `date` takes precedence. If neither is provided, defaults to today.

**Example Requests:**

Get visits for a specific date:
```
GET /visits?date=2026-01-23
```

Get visits for an entire month:
```
GET /visits?month=2026-01
```

Get visits for a specific outlet:
```
GET /visits?date=2026-01-23&outletCode=OUT_001
```

Get visits for a specific salesrep:
```
GET /visits?month=2026-01&salesrepUsername=john.doe&limit=100
```

**Response:** `200 OK`
```json
[
  {
    "id": 500,
    "tenantId": "tenant123",
    "planId": 100,
    "salesrepUsername": "john.doe",
    "outletCode": "OUT_001",
    "visitedAt": "2026-01-23T14:30:00+05:30",
    "lat": 12.9716,
    "lng": 77.5946,
    "visitType": "PLANNED",
    "remarks": "Order placed",
    "extendedAttr": {},
    "createdAt": "2026-01-23T14:30:00Z"
  }
]
```

---

## Data Models

### Beat
```typescript
{
  id: number;
  tenantId: string;
  code: string;           // Unique beat code
  name: string;           // Display name
  territory: string;      // Territory/zone name
  active: boolean;        // Is beat active
  extendedAttr: object;   // Custom attributes
  createdAt: timestamp;
}
```

### PjpMaster
```typescript
{
  id: number;
  tenantId: string;
  salesrep: string;           // Username of salesrep
  beatCode: string;           // Optional: Reference to beat
  routeCode: string;          // Optional: Reference to route
  frequency: string;          // Typically MONTHLY with flattened weeks
  week1: string[];            // ["MON", "WED"]
  week2: string[];            // ["MON", "WED"]
  week3: string[];            // ["MON", "WED"]
  week4: string[];            // ["MON", "WED"]
  week5: string[];            // ["MON", "WED"]
  week6: string[];            // ["MON", "WED"]
  active: boolean;
  extendedAttr: object;
  createdAt: timestamp;
  outlets?: PjpOutletMapItem[]; // Optional for bulk create/update
}
```

### PjpOutletMapItem
```typescript
{
  id: number;
  tenantId: string;
  pjpId: number;
  outletCode: string;
  sequenceNo: number;      // Visit order (1, 2, 3, ...)
  latitude: number;        // Optional GPS coordinate
  longitude: number;       // Optional GPS coordinate
  extendedAttr: object;
  createdAt: timestamp;
}
```

### VisitPlan
```typescript
{
  id: number;
  tenantId: string;
  visitDate: date;              // YYYY-MM-DD
  salesrepUsername: string;
  outletCode: string;
  plannedSequence: number;      // Visit order
  status: string;               // PLANNED | COMPLETED | SKIPPED | CANCELLED
  extendedAttr: object;
  createdAt: timestamp;
}
```

### VisitLog
```typescript
{
  id: number;
  tenantId: string;
  planId: number;               // Optional reference to visit_plan
  salesrepUsername: string;
  outletCode: string;
  visitedAt: timestamp;         // When visit occurred
  lat: number;                  // GPS latitude
  lng: number;                  // GPS longitude
  visitType: string;            // PLANNED | UNPLANNED | EMERGENCY
  remarks: string;              // Free-text notes
  extendedAttr: object;         // Custom data
  createdAt: timestamp;
}
```

---

## Examples

### Example 1: Daily PJP
Create a PJP where the salesrep visits all outlets every day:

```json
POST /pjp
{
  "salesrep": "john.doe",
  "beatCode": "BEAT_DAILY",
  "frequency": "MONTHLY",
  "week1": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "week2": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "week3": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "week4": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "week5": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "week6": ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
  "active": true,
  "outlets": [
    {"outletCode": "OUT_001", "sequenceNo": 1},
    {"outletCode": "OUT_002", "sequenceNo": 2},
    {"outletCode": "OUT_003", "sequenceNo": 3}
  ]
}
```

### Example 2: Weekly PJP (Mon, Wed, Fri)
Create a PJP for visits on Monday, Wednesday, and Friday:

```json
POST /pjp
{
  "salesrep": "jane.smith",
  "beatCode": "BEAT_MWF",
  "frequency": "MONTHLY",
  "week1": ["MON", "WED", "FRI"],
  "week2": ["MON", "WED", "FRI"],
  "week3": ["MON", "WED", "FRI"],
  "week4": ["MON", "WED", "FRI"],
  "week5": ["MON", "WED", "FRI"],
  "week6": ["MON", "WED", "FRI"],
  "active": true,
  "outlets": [
    {"outletCode": "OUT_010", "sequenceNo": 1},
    {"outletCode": "OUT_011", "sequenceNo": 2}
  ]
}
```

### Example 3: Monthly PJP (1st and 3rd Monday)
Create a PJP for the 1st and 3rd Monday of each month:

```json
POST /pjp
{
  "salesrep": "bob.jones",
  "beatCode": "BEAT_MONTHLY",
  "frequency": "MONTHLY",
  "week1": ["MON"],
  "week2": [],
  "week3": ["MON"],
  "week4": [],
  "week5": [],
  "week6": [],
  "active": true,
  "outlets": [
    {"outletCode": "OUT_020", "sequenceNo": 1}
  ]
}
```

### Example 4: Generate and Execute Visit Plan

**Step 1:** Generate visit plan for tomorrow
```
POST /visit-plan/generate?date=2026-01-24
Response: {"inserted": 12}
```

**Step 2:** Get the plan for a salesrep
```
GET /visit-plan?date=2026-01-24&salesrepUsername=john.doe
Response: [
  {
    "id": 200,
    "visitDate": "2026-01-24",
    "salesrepUsername": "john.doe",
    "outletCode": "OUT_001",
    "plannedSequence": 1,
    "status": "PLANNED"
  },
  ...
]
```

**Step 3:** Log the visit
```
POST /visits
{
  "planId": 200,
  "salesrepUsername": "john.doe",
  "outletCode": "OUT_001",
  "visitedAt": "2026-01-24T10:30:00+05:30",
  "lat": 12.9716,
  "lng": 77.5946,
  "visitType": "PLANNED",
  "remarks": "Successful visit, order placed"
}
```

### Example 5: Track Monthly Performance

Get all visits for a salesrep in January 2026:
```
GET /visits?month=2026-01&salesrepUsername=john.doe&limit=500
```

This returns all visits logged by john.doe in January, useful for:
- Performance tracking
- Route compliance analysis
- Visit frequency reports
- GPS tracking verification

---

## PJP Generation Algorithm

The visit plan generation follows these rules:

### DAILY Frequency
- Generates visits for **every day**
- No weekPattern or weeksOfMonth needed

### WEEKLY Frequency
- Generates visits only on specified weekdays
- Example: `weekPattern: ["MON", "WED", "FRI"]` → visits on Mon, Wed, Fri every week

### BIWEEKLY Frequency
- Generates visits every other week on specified weekdays
- Alternates based on week number since PJP creation
- Example: `weekPattern: ["TUE", "THU"]` → visits on Tue, Thu every alternate week

### MONTHLY Frequency
- Generates visits on specific week occurrences of specific weekdays
- Example: `weekPattern: ["MON"], weeksOfMonth: [1, 3]` → 1st and 3rd Monday
- Special: `weeksOfMonth: [5]` → Last occurrence (even if it's the 4th week)

### Duplicate Prevention
- The system prevents duplicate visit plans
- Uniqueness constraint: `(visitDate, salesrepUsername, outletCode)`
- If a plan already exists, it won't be recreated

---

## Best Practices

### 1. PJP Design
- Keep outlet sequences logical (geographic order)
- Use meaningful beat codes and names
- Set realistic visit frequencies
- Include GPS coordinates for route optimization

### 2. Visit Plan Generation
- Generate plans in advance (e.g., weekly batch)
- Run generation daily for next-day plans
- Monitor `inserted` count for anomalies

### 3. Visit Logging
- Always include GPS coordinates when available
- Use `planId` to link to planned visits
- Capture visit duration in `extendedAttr`
- Log unplanned visits with `visitType: "UNPLANNED"`

### 4. Performance Monitoring
- Use monthly queries for performance reports
- Track planned vs. actual visits
- Monitor visit duration and timing
- Analyze route compliance

### 5. Data Quality
- Validate outlet codes before PJP creation
- Ensure salesrep usernames are correct
- Use consistent timezone formats
- Clean up inactive PJPs regularly

---

## Error Handling

### Common Error Responses

**400 Bad Request**
```json
{
  "error": "Invalid frequency",
  "message": "Frequency must be DAILY, WEEKLY, BIWEEKLY, or MONTHLY"
}
```

**404 Not Found**
```json
{
  "error": "PJP not found",
  "message": "No PJP found with ID 999"
}
```

**409 Conflict**
```json
{
  "error": "Duplicate beat code",
  "message": "Beat with code BEAT_001 already exists"
}
```

---

## Authentication & Authorization

All endpoints require:
- **Authorization Header:** `Bearer {token}`
- **X-Tenant-Id Header:** `{tenantId}`

Example:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
X-Tenant-Id: tenant123
Content-Type: application/json
```

---

## Rate Limits

- **Standard endpoints:** 100 requests/minute
- **Bulk operations:** 10 requests/minute
- **Visit plan generation:** 20 requests/hour

---

## Changelog

### Version 1.0 (2026-01-23)
- Initial release
- Beat management APIs
- PJP CRUD operations
- Visit plan generation
- Visit log tracking
- Support for DAILY, WEEKLY, BIWEEKLY, MONTHLY frequencies

---

## Support

For questions or issues:
- Email: support@salescode.ai
- Documentation: https://docs.salescode.ai/pjp
- API Status: https://status.salescode.ai
