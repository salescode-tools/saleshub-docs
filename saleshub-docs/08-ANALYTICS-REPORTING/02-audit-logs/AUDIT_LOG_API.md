# 📋 Audit Log API Documentation

The Audit Log API provides a comprehensive trail of system activities, user actions, and data modifications within the Saleshub platform. It is essential for security auditing, troubleshooting, and compliance tracking.

---

## 🏗️ Core Concept: Audit Trail

The Audit Log captures critical events across the platform, including authentication attempts, user profile changes, configuration updates, and core business data modifications (e.g., product or outlet changes). Every log entry is immutable and scoped to a specific tenant.

---

## 📊 Audit Log Model

Every audit log entry contains the following technical details:

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | Long | Unique identifier for the audit log entry. |
| `tenantId` | String | ID of the tenant where the event occurred. |
| `userId` | Long | ID of the user who performed the action (if applicable). |
| `username` | String | Username of the actor. |
| `operationType` | String | Specific action performed (see list below). |
| `operationCategory`| String | High-level category of the action. |
| `resourceType` | String | Type of entity affected (e.g., `USER`, `PRODUCT`, `TENANT`). |
| `resourceId` | String | ID of the specific entity affected. |
| `ipAddress` | String | IP address from which the request originated. |
| `userAgent` | String | Browser or client application signature. |
| `status` | String | Outcome of the operation (`SUCCESS`, `FAILURE`, `ERROR`). |
| `failureReason` | String | Detailed error message if the operation failed. |
| `details` | Map | JSON object containing additional context (e.g., changed fields). |
| `occurredAt` | Instant | Exact timestamp when the event happened. |

---

## 📁 Operation Categories & Types

Common operation categories and their associated types:

*   **AUTHENTICATION**: `LOGIN_SUCCESS`, `LOGIN_FAILURE`, `LOGOUT`, `TOKEN_REFRESH`
*   **USER_MANAGEMENT**: `USER_CREATED`, `USER_UPDATED`, `USER_DELETED`, `PASSWORD_CHANGED`
*   **CONFIGURATION**: `TENANT_CREATED`, `SETTINGS_UPDATED`
*   **DATA_MODIFICATION**: `PRODUCT_CREATED`, `PRODUCT_UPDATED`, `OUTLET_CREATED`, `OUTLET_UPDATED`, `ORDER_CREATED`, `ORDER_UPDATED`, `ORDER_STATUS_CHANGED`
*   **SYSTEM**: `SYSTEM_ERROR`, `SYSTEM_WARNING`

---

## 🚀 API Endpoints

### 1. Search Audit Logs
Retrieve a list of audit logs based on various filters.

- **Endpoint**: `GET /audit-logs`
- **Auth Required**: ✅ (Admin permissions typically required)

#### Query Parameters:
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `username` | String | `null` | Filter by the user who performed the action. |
| `operationType` | String | `null` | Filter by specific operation (e.g., `LOGIN_FAILURE`). |
| `operationCategory`| String | `null` | Filter by high-level category (e.g., `AUTHENTICATION`). |
| `resourceType` | String | `null` | Filter by entity type (e.g., `PRODUCT`). |
| `status` | String | `null` | Filter by outcome (`SUCCESS` or `FAILURE`). |
| `fromDate` | String | `null` | Start date (YYYY-MM-DD). |
| `toDate` | String | `null` | End date (YYYY-MM-DD). |
| `limit` | Integer | `50` | Maximum results to return. |
| `offset` | Integer | `0` | Pagination start point. |

**Success Response (200 OK):**
```json
{
  "total": 125,
  "limit": 50,
  "offset": 0,
  "hasMore": true,
  "data": [
    {
      "id": 1024,
      "tenantId": "acme_corp",
      "userId": 42,
      "username": "john.doe",
      "operationType": "LOGIN_SUCCESS",
      "operationCategory": "AUTHENTICATION",
      "resourceType": "USER",
      "resourceId": "42",
      "ipAddress": "192.168.1.1",
      "userAgent": "Mozilla/5.0...",
      "status": "SUCCESS",
      "failureReason": null,
      "details": {
         "method": "PASSWORD"
      },
      "occurredAt": "2025-11-25T14:30:00Z",
      "createdAt": "2025-11-25T14:30:01Z"
    }
  ]
}
```

---

### 2. Get Audit Log Detail
Retrieve full details of a single audit log entry by its ID.

- **Endpoint**: `GET /audit-logs/{id}`
- **Auth Required**: ✅

**Success Response (200 OK):**
```json
{
  "id": 1024,
  "username": "admin_user",
  "operationType": "SETTINGS_UPDATED",
  "operationCategory": "CONFIGURATION",
  "status": "SUCCESS",
  "occurredAt": "2025-11-25T14:30:00Z",
  "details": {
    "feature": "catalog",
    "key": "distributor_search_radius_km",
    "oldValue": "5.0",
    "newValue": "10.0"
  }
}
```

---

### 3. Get Search Metadata
Retrieve available operation categories, types, and resource types for filtering.

- **Endpoint**: `GET /audit-logs/metadata`
- **Auth Required**: ✅

**Success Response (200 OK):**
```json
{
  "categories": ["AUTHENTICATION", "CONFIGURATION", "DATA_MODIFICATION", ...],
  "operationTypes": [
    { "code": "LOGIN_SUCCESS", "category": "AUTHENTICATION" },
    ...
  ],
  "resourceTypes": ["TENANT", "USER", "PRODUCT", "OUTLET", "ORDER", "ROLE", "SETTINGS"],
  "statuses": ["SUCCESS", "FAILURE", "ERROR"]
}
```

---

## �️ Filtering Metadata

When querying the audit logs, use the following standardized values for precise filtering.

### 🏷️ Operation Categories
High-level groupings for operations.
*   `AUTHENTICATION`: Login, logout, and token activities.
*   `USER_MANAGEMENT`: User creation, updates, and permission changes.
*   `ROLE_MANAGEMENT`: Creation and assignment of security roles.
*   `CONFIGURATION`: Tenant setup and system-wide setting changes.
*   `DATA_MODIFICATION`: Changes to core entities like Products, Outlets, and Orders.
*   **Status Indicators**: Every category supports outcomes like `SUCCESS`, `FAILURE`, or `ERROR`.

### 📦 Resource Types
Types of entities targeted by the operations. Supported values include:
*   `TENANT`: Platform-level organizational units.
*   `USER`: Individual user accounts and profiles.
*   `PRODUCT`: Catalog entries and SKU data.
*   `OUTLET`: Retail point-of-sale locations.
*   `ORDER`: Sales transactions and status updates.
*   `ROLE`: Security and permission definitions.

---

## �🔗 Related Documentation
- [Security & Governance](./META_FEATURE_REFERENCE.md#8-security-governance--compliance) - Overview of platform protection.
- [User Registration API](./USER_REGISTRATION_API.md) - Context on user lifecycle events.
