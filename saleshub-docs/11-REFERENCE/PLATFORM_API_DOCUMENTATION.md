# 🚀 Salescodeai Saleshub Platform API Documentation

>> **Version:** 1.1  
> **Last Updated:** 2025-11-21

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Getting Started](#-getting-started)
- [Authentication](#-authentication)
- [API Modules](#-api-modules)
  - [Authentication & Authorization](#-authentication--authorization)
  - [User Management](#-user-management)
  - [Organization Hierarchy](#-organization-hierarchy)
  - [Organization Location & Geography](#-organization-location--geography)
  - [Outlet Management](#-outlet-management)
  - [Product & Catalog](#-product--catalog)
  - [Order Management](#-order-management)
  - [Sales & Analytics](#-sales--analytics)
  - [PJP & Field Operations](#-pjp--field-operations)
  - [Targets & KPIs](#-targets--kpis)
  - [Gamification & Tasks](#-gamification--tasks)
  - [Recommendations (ML)](#-recommendations-ml)
  - [Promotions](#-promotions)
  - [Order Promo Audit](#-order-promo-audit)
  - [Settings & Configuration](#-settings--configuration)
  - [Data Ingestion](#-data-ingestion)
  - [OAuth & External Integration](#-oauth--external-integration)
  - [Tax Management](#-tax-management)
- [Common Patterns](#-common-patterns)
- [Error Handling](#-error-handling)
- [Best Practices](#-best-practices)

---

## 🎯 Overview

Salescodeai Saleshub Platform API is a **comprehensive multi-tenant B2B sales management platform** that provides enterprise-grade APIs for managing the entire sales lifecycle, from catalog management to order processing, field force automation, and ML-driven recommendations.

### 🏗️ Architecture Principles

**Multi-Tenant Design**
- Enterprise-grade data isolation between tenants
- Tenant context automatically injected via `X-Tenant-Id` header
- Secure, scalable multi-tenancy architecture

**RESTful Standards**
- Standard HTTP methods (GET, POST, PUT, PATCH, DELETE)
- JSON request/response format
- Proper HTTP status codes
- Pagination support on list endpoints

**Security First**
- JWT-based authentication
- Role-based access control (RBAC)
- Industry-standard password encryption
- Tenant-scoped data access

---

## 🚀 Getting Started

### Base URL

```
https://api.salescodeai.com/v1
```

> Replace with your organization's API endpoint URL

### Required Headers

All authenticated requests must include:

```http
Content-Type: application/json
Authorization: Bearer <jwt-token>
X-Tenant-Id: <tenant-id>
```

### Quick Start Example

```bash
# 1. Register a new tenant
curl -X POST https://api.salescodeai.com/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "tenantName": "Acme Corp",
    "firstName": "John",
    "lastName": "Doe",
    "username": "john.doe@acme.com",
    "password": "SecurePass123!",
    "email": "john.doe@acme.com"
  }'

# 2. Login
curl -X POST https://api.salescodeai.com/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "tenantId": "acme_corp",
    "username": "john.doe@acme.com",
    "password": "SecurePass123!"
  }'

# 3. Use the token for authenticated requests
curl -X GET https://api.salescodeai.com/v1/products \
  -H "Authorization: Bearer <token-from-login>" \
  -H "X-Tenant-Id: acme_corp"
```

---

## 🔐 Authentication

### POST /auth/register

Register a new tenant with an admin user.

**Request Body:**
```json
{
  "tenantId": "acme_corp",
  "tenantName": "Acme Corporation",
  "firstName": "John",
  "lastName": "Doe",
  "username": "john.doe@acme.com",
  "password": "SecurePass123!",
  "email": "john.doe@acme.com",
  "phone": "+1-555-0123"
}
```

**Success Response (201 Created):**
```json
{
  "tenantId": "acme_corp",
  "userId": 1,
  "username": "john.doe@acme.com",
  "roles": ["TENANT_ADMIN"],
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2025-11-22T10:00:00Z"
}
```

**Error Responses:**
- `400 Bad Request` - Missing required fields
- `409 Conflict` - Tenant or username already exists

---

### POST /auth/login

Authenticate and receive a JWT token.

**Request Body:**
```json
{
  "tenantId": "acme_corp",
  "username": "john.doe@acme.com",
  "password": "SecurePass123!"
}
```

**Success Response (200 OK):**
```json
{
  "tenantId": "acme_corp",
  "userId": 1,
  "username": "john.doe@acme.com",
  "roles": ["TENANT_ADMIN", "SALES_REP"],
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2025-11-22T10:00:00Z"
}
```

**Error Responses:**
- `400 Bad Request` - Missing credentials
- `401 Unauthorized` - Invalid credentials

---

### OAuth 2.0 Client Credentials

For external applications and system-to-system integrations, Saleshub supports the OAuth 2.0 Client Credentials flow.

**Endpoints:**
- `POST /oauth/token` : Obtain access token using client id and secret.
- `POST /oauth/clients` : Register a new integration app (Admin only).

For full details, see the [OAuth API Documentation](./OAUTH_API.md).

---

## 👥 User Management

### GET /users

List all users with optional filtering and pagination.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `q` | string | ❌ | Search query (name, username) | `john` |
| `orgType` | string | ❌ | Organization type filter | `DISTRIBUTOR` |
| `orgCode` | string | ❌ | Organization code filter | `DIST-001` |
| `limit` | integer | ❌ | Max results (default: 25) | `50` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "firstName": "John",
    "lastName": "Doe",
    "username": "john.doe@acme.com",
    "email": "john.doe@acme.com",
    "phone": "+1-555-0123",
    "orgType": "DISTRIBUTOR",
    "orgCode": "DIST-001",
    "active": true,
    "createdAt": "2025-11-20T10:00:00Z"
  }
]
```

---

### POST /users

Create a new user.

**Request Body:**
```json
{
  "firstName": "Jane",
  "lastName": "Smith",
  "username": "jane.smith@acme.com",
  "password": "SecurePass123!",
  "email": "jane.smith@acme.com",
  "phone": "+1-555-0124",
  "orgType": "OUTLET",
  "orgCode": "OUT-001"
}
```

**Success Response (201 Created):**
```json
{
  "id": 2,
  "firstName": "Jane",
  "lastName": "Smith",
  "username": "jane.smith@acme.com",
  "email": "jane.smith@acme.com",
  "phone": "+1-555-0124",
  "orgType": "OUTLET",
  "orgCode": "OUT-001",
  "active": true,
  "createdAt": "2025-11-21T10:00:00Z"
}
```

**Error Responses:**
- `400 Bad Request` - Missing required fields
- `409 Conflict` - Username already exists

---

### PUT /users/{id}

Update an existing user.

**Path Parameters:**
- `id` - User ID

**Request Body:**
```json
{
  "firstName": "Jane",
  "lastName": "Smith-Updated",
  "email": "jane.updated@acme.com",
  "phone": "+1-555-9999"
}
```

**Success Response (204 No Content)**

---

### DELETE /users/{userId}

Delete a user.

**Path Parameters:**
- `userId` - User ID

**Success Response (204 No Content)**

**Error Responses:**
- `404 Not Found` - User not found

---

## � Organization Hierarchy

The Organization Hierarchy API manages organizational structure types and their relationships. This enables flexible multi-level hierarchies like Region → Zone → Territory → Beat.

### GET /org-types

List all organization types with optional filtering.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `q` | string | ❌ | Search query (code, name) | `region` |
| `parent` | string | ❌ | Filter by parent type code | `COUNTRY` |
| `limit` | integer | ❌ | Max results (default: 100) | `50` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "code": "REGION",
    "name": "Sales Region",
    "description": "Top-level sales region",
    "parentCode": null,
    "level": 1,
    "active": true
  },
  {
    "id": 2,
    "code": "ZONE",
    "name": "Sales Zone",
    "description": "Zone within a region",
    "parentCode": "REGION",
    "level": 2,
    "active": true
  }
]
```

**Use Cases:**
- Define organizational structure (Region → Zone → Territory)
- Create hierarchical reporting structures
- Enable territory-based access control
- Support multi-level sales organization

---

### GET /org-types/{code}

Get a specific organization type by code.

**Path Parameters:**
- `code` - Organization type code

**Success Response (200 OK):**
```json
{
  "id": 1,
  "code": "REGION",
  "name": "Sales Region",
  "description": "Top-level sales region",
  "parentCode": null,
  "level": 1,
  "active": true
}
```

**Error Responses:**
- `404 Not Found` - Organization type not found

---

### POST /org-types

Create a new organization type.

**Request Body:**
```json
{
  "code": "TERRITORY",
  "name": "Sales Territory",
  "description": "Territory within a zone",
  "parentCode": "ZONE",
  "level": 3,
  "active": true
}
```

**Success Response (200 OK):**
```json
{
  "id": 3,
  "code": "TERRITORY",
  "name": "Sales Territory",
  "description": "Territory within a zone",
  "parentCode": "ZONE",
  "level": 3,
  "active": true
}
```

**Error Responses:**
- `400 Bad Request` - Missing code or invalid data
- `409 Conflict` - Code already exists

---

### PUT /org-types/{id}

Update an organization type.

**Path Parameters:**
- `id` - Organization type ID or code

**Request Body:**
```json
{
  "name": "Sales Territory Updated",
  "description": "Updated description",
  "active": true
}
```

**Success Response (200 OK):**
```json
{
  "id": 3,
  "code": "TERRITORY",
  "name": "Sales Territory Updated",
  "description": "Updated description",
  "parentCode": "ZONE",
  "level": 3,
  "active": true
}
```

---

### DELETE /org-types/{id}

Delete an organization type.

**Path Parameters:**
- `id` - Organization type ID or code

**Success Response (204 No Content)**

**Error Responses:**
- `404 Not Found` - Organization type not found
- `409 Conflict` - Cannot delete if child types exist

---

### GET /distributors

List all distributors with optional filtering.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `q` | string | ❌ | Search query (code, name) | `mumbai` |
| `limit` | integer | ❌ | Max results (default: 25) | `50` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "code": "DIST-001",
    "name": "Mumbai Distributors Ltd",
    "address": "123 Warehouse St, Mumbai",
    "phone": "+91-22-12345678",
    "lat": 19.0760,
    "lon": 72.8777,
    "extendedAttr": {
      "gst": "27AABCU9603R1ZM",
      "creditLimit": 5000000
    },
    "active": true
  }
]
```

---

### GET /distributors/{id}

Get a specific distributor by ID.

**Path Parameters:**
- `id` - Distributor ID

**Success Response (200 OK):**
```json
{
  "id": 1,
  "code": "DIST-001",
  "name": "Mumbai Distributors Ltd",
  "address": "123 Warehouse St, Mumbai",
  "phone": "+91-22-12345678",
  "lat": 19.0760,
  "lon": 72.8777,
  "active": true
}
```

---

### POST /distributors

Create a new distributor with optional user assignments.

**Request Body:**
```json
{
  "code": "DIST-002",
  "name": "Delhi Distributors Pvt Ltd",
  "address": "456 Industrial Area, Delhi",
  "phone": "+91-11-98765432",
  "lat": 28.6139,
  "lon": 77.2090,
  "extendedAttr": {
    "gst": "07AABCU9603R1ZM"
  },
  "contacts": [
    {
      "username": "dist.manager",
      "password": "Pass123!",
      "firstName": "Rajesh",
      "lastName": "Kumar",
      "email": "rajesh@delhidist.com"
    }
  ]
}
```

**Success Response (201 Created):**
```json
{
  "distributor": {
    "id": 2,
    "code": "DIST-002",
    "name": "Delhi Distributors Pvt Ltd",
    "address": "456 Industrial Area, Delhi",
    "phone": "+91-11-98765432",
    "active": true,
    "extendedAttr": {
      "gst": "07AABCU9603R1ZM"
    },
    "contacts": [
        {
          "id": 10,
          "username": "dist.manager",
          "firstName": "Rajesh",
          "lastName": "Kumar",
          "email": "rajesh@delhidist.com"
        }
    ]
  }
}
```
**Note**: The response structure wraps only the Distributor object, which now contains `contacts`.

**Error Responses:**
- `400 Bad Request` - Missing code or name
- `409 Conflict` - Distributor code already exists

---

### PUT /distributors/{idOrCode}

Update an existing distributor by ID or Code.

**Path Parameters:**
- `idOrCode` - Distributor ID or Distributor Code

**Request Body:**
```json
{
  "name": "Delhi Distributors Adjusted Name",
  "address": "New Address line",
  "phone": "+91-11-00000000",
  "extendedAttr": {
    "gst": "07AABCU9603R1ZM",
    "creditLimit": 100000
  },
  "contacts": [
    {
      "username": "dist.manager",
      "firstName": "Rajesh",
      "lastName": "Kumar Updated",
      "phone": "+91-9999999999"
    }
  ]
}
```
**Note**: When providing `contacts`, the list is treated as the **complete** set of associated users. Any previously linked users NOT present in this list will be removed from the distributor. To add a user without removing others, you must include all existing users in the list.

**Success Response (200 OK):**
```json
{
  "id": 2,
  "code": "DIST-002",
  "name": "Delhi Distributors Adjusted Name",
  "address": "New Address line",
  "phone": "+91-11-00000000",
  "active": true,
  "extendedAttr": {
    "gst": "07AABCU9603R1ZM",
    "creditLimit": 100000
  }
}
```

**Error Responses:**
- `404 Not Found` - Distributor not found
- `400 Bad Request` - Invalid body

---

### DELETE /distributors/{id}

Delete a distributor.

**Path Parameters:**
- `id` - Distributor ID

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `cleanup` | boolean | ❌ | Delete all associated data (orders, pricing, etc.) | `true` |

**Success Response (204 No Content)**

---

## 🗺️ Organization Location & Geography

The Organization Location API manages geographical hierarchies and location-based organizational structures. This supports territory mapping, geo-fencing, and location-based analytics.

### Location Definition Management

#### GET /org/location-defs

List all location definition types (e.g., Country, State, City, Pincode).

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `q` | string | ❌ | Search query (code, name) | `state` |
| `limit` | integer | ❌ | Max results (default: 50) | `100` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "code": "COUNTRY",
    "name": "Country",
    "level": 1,
    "parents": null,
    "description": "Top-level country definition",
    "isBuiltin": true
  },
  {
    "id": 2,
    "code": "STATE",
    "name": "State/Province",
    "level": 2,
    "parents": ["COUNTRY"],
    "description": "State or province within a country",
    "isBuiltin": true
  },
  {
    "id": 3,
    "code": "CITY",
    "name": "City",
    "level": 3,
    "parents": ["STATE"],
    "description": "City or municipality",
    "isBuiltin": false
  }
]
```

**Field Descriptions:**
- `code` - Unique identifier for the location type
- `name` - Display name
- `level` - Hierarchy level (1 = top, higher = deeper)
- `parents` - Array of valid parent location type codes
- `isBuiltin` - Whether this is a system-defined type

---

#### GET /org/location-defs/{code}

Get a specific location definition by code.

**Path Parameters:**
- `code` - Location definition code

**Success Response (200 OK):**
```json
{
  "id": 2,
  "code": "STATE",
  "name": "State/Province",
  "level": 2,
  "parents": ["COUNTRY"],
  "description": "State or province within a country",
  "isBuiltin": true
}
```

---

#### POST /org/location-defs

Create a new location definition type.

**Request Body:**
```json
{
  "code": "DISTRICT",
  "name": "District",
  "level": 4,
  "parents": ["CITY", "STATE"],
  "description": "District or sub-region",
  "isBuiltin": false
}
```

**Success Response (200 OK):**
```json
{
  "id": 4,
  "code": "DISTRICT",
  "name": "District",
  "level": 4,
  "parents": ["CITY", "STATE"],
  "description": "District or sub-region",
  "isBuiltin": false
}
```

**Use Cases:**
- Define custom location hierarchies
- Support country-specific administrative divisions
- Create flexible geo-hierarchies (Country → State → City → Pincode)
- Enable location-based reporting and analytics

---

#### PUT /org/location-defs/{code}

Update a location definition.

**Path Parameters:**
- `code` - Location definition code

**Request Body:**
```json
{
  "name": "District Updated",
  "parents": ["CITY"],
  "description": "Updated description",
  "isBuiltin": false
}
```

**Success Response (200 OK)**

---

#### DELETE /org/location-defs/{code}

Delete a location definition.

**Path Parameters:**
- `code` - Location definition code

**Success Response (200 OK):**
```json
{
  "deleted": true
}
```

**Error Responses:**
- `404 Not Found` - Location definition not found
- `409 Conflict` - Cannot delete if locations of this type exist

---

### Location Instance Management

#### GET /org/locations

List all location instances with optional filtering.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `q` | string | ❌ | Search query (code, name) | `mumbai` |
| `level` | string | ❌ | Filter by location type | `CITY` |
| `limit` | integer | ❌ | Max results (default: 50) | `100` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "code": "IN",
    "name": "India",
    "level": "COUNTRY",
    "parentCode": null,
    "lat": 20.5937,
    "lon": 78.9629,
    "geoBoundary": null,
    "timezone": "Asia/Kolkata",
    "addressLine1": null,
    "addressLine2": null,
    "cityName": null,
    "stateName": null,
    "countryName": "India",
    "pincode": null,
    "extendedAttr": {
      "isoCode": "IN",
      "currency": "INR"
    }
  },
  {
    "id": 2,
    "code": "MH",
    "name": "Maharashtra",
    "level": "STATE",
    "parentCode": "IN",
    "lat": 19.7515,
    "lon": 75.7139,
    "geoBoundary": null,
    "timezone": "Asia/Kolkata",
    "stateName": "Maharashtra",
    "countryName": "India",
    "extendedAttr": {
      "capital": "Mumbai"
    }
  }
]
```

**Field Descriptions:**
- `code` - Unique location code
- `name` - Location name
- `level` - Location type (references location definition)
- `parentCode` - Parent location code (hierarchical relationship)
- `lat/lon` - Geographic coordinates
- `geoBoundary` - GeoJSON polygon for geo-fencing (optional)
- `timezone` - IANA timezone identifier
- `extendedAttr` - Additional custom attributes (JSONB)

---

#### GET /org/locations/{code}

Get a specific location by code.

**Path Parameters:**
- `code` - Location code

**Success Response (200 OK):**
```json
{
  "id": 3,
  "code": "MUM",
  "name": "Mumbai",
  "level": "CITY",
  "parentCode": "MH",
  "lat": 19.0760,
  "lon": 72.8777,
  "geoBoundary": {
    "type": "Polygon",
    "coordinates": [[[72.7, 18.9], [72.9, 18.9], [72.9, 19.2], [72.7, 19.2], [72.7, 18.9]]]
  },
  "timezone": "Asia/Kolkata",
  "cityName": "Mumbai",
  "stateName": "Maharashtra",
  "countryName": "India",
  "pincode": null,
  "extendedAttr": {
    "population": 20000000,
    "area": 603.4
  }
}
```

---

#### POST /org/locations

Create a new location instance.

**Request Body:**
```json
{
  "code": "DEL",
  "name": "Delhi",
  "level": "CITY",
  "parentCode": "DL",
  "lat": 28.6139,
  "lon": 77.2090,
  "geoBoundary": {
    "type": "Polygon",
    "coordinates": [[[77.0, 28.4], [77.4, 28.4], [77.4, 28.8], [77.0, 28.8], [77.0, 28.4]]]
  },
  "timezone": "Asia/Kolkata",
  "addressLine1": null,
  "addressLine2": null,
  "cityName": "Delhi",
  "stateName": "Delhi",
  "countryName": "India",
  "pincode": null,
  "extendedAttr": {
    "population": 30000000,
    "isCapital": true
  }
}
```

**Success Response (200 OK):**
```json
{
  "id": 4,
  "code": "DEL",
  "name": "Delhi",
  "level": "CITY",
  "parentCode": "DL",
  "lat": 28.6139,
  "lon": 77.2090,
  "timezone": "Asia/Kolkata"
}
```

**Use Cases:**
- **Territory Management:** Define sales territories with geo-boundaries
- **Geo-fencing:** Check if outlets/visits are within designated areas
- **Location-based Analytics:** Aggregate sales by city, state, region
- **Route Planning:** Optimize sales rep routes based on geography
- **Hierarchical Reporting:** Roll up metrics from city → state → country

---

#### PUT /org/locations/{code}

Update a location instance.

**Path Parameters:**
- `code` - Location code

**Request Body:**
```json
{
  "name": "Mumbai Metropolitan Region",
  "lat": 19.0760,
  "lon": 72.8777,
  "geoBoundary": {
    "type": "Polygon",
    "coordinates": [[[72.6, 18.8], [73.0, 18.8], [73.0, 19.3], [72.6, 19.3], [72.6, 18.8]]]
  },
  "extendedAttr": {
    "population": 25000000
  }
}
```

**Success Response (200 OK)**

---

#### DELETE /org/locations/{code}

Delete a location instance.

**Path Parameters:**
- `code` - Location code

**Success Response (200 OK):**
```json
{
  "deleted": true
}
```

**Error Responses:**
- `404 Not Found` - Location not found
- `409 Conflict` - Cannot delete if child locations exist

---

### Location Hierarchy Example

```
Country (IN - India)
  └── State (MH - Maharashtra)
      └── City (MUM - Mumbai)
          └── District (MUM-S - South Mumbai)
              └── Pincode (400001)
```

**Creating this hierarchy:**

```bash
# 1. Create country
POST /org/locations
{
  "code": "IN",
  "name": "India",
  "level": "COUNTRY",
  "parentCode": null
}

# 2. Create state
POST /org/locations
{
  "code": "MH",
  "name": "Maharashtra",
  "level": "STATE",
  "parentCode": "IN"
}

# 3. Create city
POST /org/locations
{
  "code": "MUM",
  "name": "Mumbai",
  "level": "CITY",
  "parentCode": "MH"
}
```

---

## �🏪 Outlet Management

### GET /outlets

List all outlets with optional filtering.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `q` | string | ❌ | Search query (code, name) | `sharma` |
| `channel` | string | ❌ | Channel filter | `RETAIL` |
| `limit` | integer | ❌ | Max results (default: 25) | `50` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |
| `outletType` | string | ❌ | Filter by outlet type | `Retail` |
| `outletCategory` | string | ❌ | Filter by outlet category | `Premium` |
| `outletClass` | string | ❌ | Filter by outlet class | `Diamond` |
| `city` | string | ❌ | Filter by city | `Mumbai` |
| `state` | string | ❌ | Filter by state | `Maharashtra` |

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "code": "OUT-001",
    "name": "Sharma General Store",
    "channel": "RETAIL",
    "address": "123 Main St, Mumbai",
    "lat": 19.0760,
    "lon": 72.8777,
    "extendedAttr": {
      "gst": "27AABCU9603R1ZM",
      "creditLimit": 50000
    },
    "email": "sharma@example.com",
    "active": true,
    "outletDivision": "FMCG",
    "routeCode": "BEAT_01"
  }
]
```

---

### GET /outlets/{outletId}

Get a specific outlet by ID.

**Path Parameters:**
- `outletId` - Outlet ID

**Success Response (200 OK):**
```json
{
  "id": 1,
  "code": "OUT-001",
  "name": "Sharma General Store",
  "channel": "RETAIL",
  "address": "123 Main St, Mumbai",
  "lat": 19.0760,
  "lon": 72.8777,
  "extendedAttr": {
    "gst": "27AABCU9603R1ZM",
    "creditLimit": 50000
  },
  "active": true
}
```

**Error Responses:**
- `404 Not Found` - Outlet not found

---

### GET /outlets/unique-values

Retrieve a list of all distinct values currently existing in the database for various outlet attributes.

**Success Response (200 OK):**
```json
{
  "types": ["Retail", "Wholesale", ...],
  "categories": ["Premium", "Standard", ...],
  "channels": ["Kirana", "Supermarket", ...],
  "subChannels": ["Small Kirana", ...],
  "classes": ["Class A", "Class B", "Diamond", "Platinum", ...],
  "divisions": ["FMCG", "Dairy", ...],
  "routeCodes": ["BEAT_01", "ROUTE_A", ...]
}
```

---

### POST /outlets

Create a new outlet with optional user assignments.

**Request Body:**
```json
{
  "code": "OUT-002",
  "name": "Kumar Traders",
  "channel": "WHOLESALE",
  "address": "456 Market Rd, Delhi",
  "email": "kumar@example.com",
  "lat": 28.6139,
  "lon": 77.2090,
  "extendedAttr": "{\"gst\":\"07AABCU9603R1ZM\"}",
  "users": [
    {
      "username": "kumar.outlet",
      "password": "Pass123!",
      "firstName": "Kumar",
      "lastName": "Patel",
      "email": "kumar@traders.com"
    }
  ]
}
```

**Success Response (201 Created):**
```json
{
  "outlet": {
    "id": 2,
    "code": "OUT-002",
    "name": "Kumar Traders",
    "channel": "WHOLESALE",
    "address": "456 Market Rd, Delhi",
    "lat": 28.6139,
    "lon": 77.2090,
    "active": true
  },
  "users": [
    {
      "id": 3,
      "username": "kumar.outlet",
      "firstName": "Kumar",
      "lastName": "Patel",
      "email": "kumar@traders.com"
    }
  ]
}
```

**Error Responses:**
- `400 Bad Request` - Missing code or name
- `409 Conflict` - Outlet code already exists

---

### DELETE /outlets/{outletId}

Delete an outlet.

**Path Parameters:**
- `outletId` - Outlet ID

**Success Response (204 No Content)**

---

## 📦 Product & Catalog

### GET /products

List all products with optional filters and search.

**Query Parameters:**
- `q` - (Optional) General search string. Automatically matches against:
  - SKU
  - Name
  - Description
  - Brand
  - Company (in `extendedAttr`)
  - Pack Size (in `extendedAttr`)
  - UOM
- `brand` - (Optional) Filter by brand
- `category` - (Optional) Filter by category
- `subcategory` - (Optional) Filter by subcategory
- `tags` - (Optional) Filter by tags
- `limit` - (Optional, default 25) Pagination limit
- `offset` - (Optional, default 0) Pagination offset
- `hierarchical` - (Optional, default true) Whether to include products from child tenants

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "sku": "PROD-001",
    "name": "Coca Cola 500ml",
    "brand": "Coca Cola",
    "category": "Beverages",
    "subcategory": "Soft Drinks",
    "unitsPerCase": 24,
    "mrp": 20.00,
    "uom": "BOTTLE",
    "imageUrl": "https://cdn.example.com/coke.jpg",
    "images": ["https://cdn.example.com/coke-1.jpg"],
    "description": "Refreshing cola drink",
    "active": true,
    "extendedAttr": {
      "barcode": "8901234567890"
    }
  }
]
```

---

### GET /products/{id}

Get a product by ID.

**Path Parameters:**
- `id` - Product ID

**Success Response (200 OK):**
```json
{
  "id": 1,
  "sku": "PROD-001",
  "name": "Coca Cola 500ml",
  "brand": "Coca Cola",
  "category": "Beverages",
  "subcategory": "Soft Drinks",
  "unitsPerCase": 24,
  "mrp": 20.00,
  "uom": "BOTTLE",
  "active": true
}
```

---

### GET /products/sku/{sku}

Get a product by SKU.

**Path Parameters:**
- `sku` - Product SKU

**Success Response (200 OK):**
```json
{
  "id": 1,
  "sku": "PROD-001",
  "name": "Coca Cola 500ml",
  "mrp": 20.00
}
```

---

### POST /products

Create a new product.

**Request Body:**
```json
{
  "sku": "PROD-002",
  "name": "Pepsi 500ml",
  "brand": "Pepsi",
  "category": "Beverages",
  "subcategory": "Soft Drinks",
  "unitsPerCase": 24,
  "mrp": 20.00,
  "uom": "BOTTLE",
  "imageUrl": "https://cdn.example.com/pepsi.jpg",
  "images": ["https://cdn.example.com/pepsi-1.jpg"],
  "description": "Refreshing cola drink",
  "active": true,
  "extendedAttr": {
    "barcode": "8901234567891"
  }
}
```

**Success Response (201 Created):**
```json
{
  "id": 2,
  "sku": "PROD-002",
  "name": "Pepsi 500ml",
  "brand": "Pepsi",
  "category": "Beverages",
  "unitsPerCase": 24,
  "mrp": 20.00,
  "active": true
}
```

**Error Responses:**
- `400 Bad Request` - Missing required fields or invalid data
- `409 Conflict` - SKU already exists

---

### PUT /products/{id}

Update a product by ID.

**Path Parameters:**
- `id` - Product ID

**Request Body (partial update):**
```json
{
  "name": "Pepsi 500ml Updated",
  "mrp": 22.00,
  "active": true
}
```

**Success Response (200 OK):**
```json
{
  "id": 2,
  "sku": "PROD-002",
  "name": "Pepsi 500ml Updated",
  "mrp": 22.00,
  "active": true
}
```

---

### PUT /products/sku/{sku}

Update a product by SKU.

**Path Parameters:**
- `sku` - Current product SKU

**Request Body:**
```json
{
  "sku": "PROD-002-NEW",
  "name": "Pepsi 500ml Renamed",
  "mrp": 22.00
}
```

**Success Response (200 OK)**

---

### POST /products/bulk-image-update

Batch update product images by SKU.

**Request Body:**
```json
{
  "items": [
    {
      "skuCode": "PROD-001",
      "images": "https://cdn.example.com/img1.jpg, https://cdn.example.com/img2.jpg"
    },
    {
      "skuCode": "PROD-002",
      "images": "https://cdn.example.com/img3.webp"
    }
  ]
}
```

**Success Response (200 OK):**
```json
{
  "message": "Bulk image update completed for 2 products"
}
```

---

### PATCH /products/{id}/active

Toggle product active status.

**Path Parameters:**
- `id` - Product ID

**Request Body:**
```json
{
  "active": false
}
```

**Success Response (200 OK)**

---

### GET /catalog

Get catalog items for an outlet with pricing and entitlements.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `outlet_code` | string | ✅ | Outlet code | `OUT-001` |
| `salesrep` | string | ❌ | Sales rep username | `john.doe` |
| `distributor` | string | ❌ | Distributor code | `DIST-001` |
| `as_of` | string | ❌ | Date (YYYY-MM-DD, default: today) | `2025-11-21` |
| `q` | string | ❌ | Search query | `cola` |
| `limit` | integer | ❌ | Max results (default: 100) | `50` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
[
  {
    "sku": "PROD-001",
    "name": "Coca Cola 500ml",
    "brand": "Coca Cola",
    "category": "Beverages",
    "unitsPerCase": 24,
    "mrp": 20.00,
    "price": 18.00,
    "discount": 10.0,
    "canSell": true,
    "priceRuleId": 5,
    "entitlementId": 3
  }
]
```

---

### GET /catalog/salesrep

Get catalog for the authenticated sales rep (uses token context).

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `outlet_code` | string | ✅ | Outlet code | `OUT-001` |
| `distributor` | string | ❌ | Distributor code | `DIST-001` |
| `as_of` | string | ❌ | Date (YYYY-MM-DD) | `2025-11-21` |
| `limit` | integer | ❌ | Max results (default: 100) | `50` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
[
  {
    "sku": "PROD-001",
    "name": "Coca Cola 500ml",
    "price": 18.00,
    "canSell": true
  }
]
```

---

## 📋 Order Management

### GET /orders

List orders with optional filtering.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `status` | integer | ❌ | Order status code | `1` |
| `from` | string | ❌ | Start date (ISO 8601) | `2025-11-01T00:00:00Z` |
| `to` | string | ❌ | End date (ISO 8601) | `2025-11-30T23:59:59Z` |
| `limit` | integer | ❌ | Max results (default: 50) | `100` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "outletCode": "OUT-001",
    "salesrepUsername": "john.doe",
    "orderNumber": "ORD-12345",
    "referenceNumber": "REF-ABC-001",
    "orderDate": "2025-11-21T10:00:00Z",
    "status": 1,
    "totalAmount": 1200.00,
    "createdAt": "2025-11-21T10:00:00Z"
  }
]
```

---

### GET /orders/{id}

Get a specific order by ID.

**Path Parameters:**
- `id` - Order ID

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `expand` | string | ❌ | Expand related data (`lines`, `all`) | `lines` |

**Success Response (200 OK):**
```json
{
  "id": 1,
  "outletCode": "OUT-001",
  "salesrepUsername": "john.doe",
  "orderNumber": "ORD-12345",
  "referenceNumber": "REF-ABC-001",
  "orderDate": "2025-11-21T10:00:00Z",
  "status": 1,
  "totalAmount": 1200.00,
  "lines": [
    {
      "id": 1,
      "orderId": 1,
      "sku": "PROD-001",
      "quantity": 10,
      "unitPrice": 18.00,
      "lineTotal": 180.00
    }
  ]
}
```

---

### POST /orders

Create a new order.

**Request Body:**
```json
{
  "outletCode": "OUT-001",
  "salesrepUsername": "john.doe",
  "referenceNumber": "REF-ABC-001",
  "orderDate": "2025-11-21T10:00:00Z",
  "notes": "Urgent delivery",
  "lines": [
    {
      "sku": "PROD-001",
      "quantity": 10,
      "unitPrice": 18.00
    },
    {
      "sku": "PROD-002",
      "quantity": 5,
      "unitPrice": 22.00
    }
  ]
}
```

**Success Response (201 Created):**
```json
{
  "order": {
    "id": 2,
    "outletCode": "OUT-001",
    "salesrepUsername": "john.doe",
    "orderNumber": "ORD-generated",
    "referenceNumber": "REF-ABC-001",
    "orderDate": "2025-11-21T10:00:00Z",
    "status": 0,
    "totalAmount": 290.00,
    "createdAt": "2025-11-21T10:05:00Z"
  }
}
```

---

### PUT /orders/{id}

Update order fields.

**Path Parameters:**
- `id` - Order ID

**Request Body:**
```json
{
  "notes": "Updated delivery instructions",
  "deliveryDate": "2025-11-22T10:00:00Z"
}
```

**Success Response (200 OK)**

---

### POST /orders/{id}/status

Change order status.

**Path Parameters:**
- `id` - Order ID

**Request Body:**
```json
{
  "statusCode": 2,
  "remarks": "Order approved"
}
```

**Success Response (200 OK)**

---

### POST /orders/{id}/lines

Add a line item to an order.

**Path Parameters:**
- `id` - Order ID

**Request Body:**
```json
{
  "sku": "PROD-003",
  "quantity": 3,
  "unitPrice": 25.00
}
```

**Success Response (200 OK):**
```json
{
  "id": 3,
  "orderId": 1,
  "sku": "PROD-003",
  "quantity": 3,
  "unitPrice": 25.00,
  "lineTotal": 75.00
}
```

---

### PUT /orders/{id}/lines/{lineId}

Update an order line item.

**Path Parameters:**
- `id` - Order ID
- `lineId` - Line item ID

**Request Body:**
```json
{
  "quantity": 5,
  "unitPrice": 24.00
}
```

**Success Response (200 OK)**

---

### DELETE /orders/{id}/lines/{lineId}

Delete an order line item.

**Path Parameters:**
- `id` - Order ID
- `lineId` - Line item ID

**Success Response (204 No Content)**

---

## 📊 Sales & Analytics

### POST /sales/upload

Upload sales data via CSV (raw binary).

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `header` | boolean | ❌ | CSV has header row (default: true) | `true` |
| `autoMasters` | boolean | ❌ | Auto-create missing masters (default: false) | `false` |

**Request Headers:**
```http
Content-Type: text/csv
Authorization: Bearer <token>
X-Tenant-Id: <tenant-id>
```

**Request Body:** (CSV file content)

**Success Response (200 OK):**
```json
{
  "processed": 150,
  "inserted": 145,
  "updated": 5,
  "errors": 0
}
```

---

### POST /sales/upload/multipart

Upload sales data via multipart form.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `header` | boolean | ❌ | CSV has header row (default: true) | `true` |
| `autoMasters` | boolean | ❌ | Auto-create missing masters (default: false) | `false` |

**Request:**
```bash
curl -X POST 'http://localhost:8080/api/sales/upload/multipart?header=true&autoMasters=true' \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-Id: acme_corp" \
  -F "file=@sales_data.csv;type=text/csv"
```

**Success Response (200 OK):**
```json
{
  "processed": 150,
  "inserted": 145,
  "updated": 5,
  "errors": 0
}
```

---

### GET /analytics/trending

Get trending products and analytics.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `period` | string | ❌ | Time period (`day`, `week`, `month`) | `week` |
| `limit` | integer | ❌ | Max results (default: 10) | `20` |

**Success Response (200 OK):**
```json
{
  "period": "week",
  "trending": [
    {
      "sku": "PROD-001",
      "name": "Coca Cola 500ml",
      "salesCount": 1250,
      "revenue": 22500.00,
      "growth": 15.5
    }
  ]
}
```

---

## 🗺️ PJP & Field Operations

For the full technical specification of the PJP schema and visit planning logic, see the [PJP API Reference](./PJP_API_REFERENCE.md).

### GET /beats

List all beats (sales routes).

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `q` | string | ❌ | Search query | `north` |
| `limit` | integer | ❌ | Max results (default: 50) | `100` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "code": "BEAT-001",
    "name": "North Mumbai Route",
    "salesrepUsername": "john.doe",
    "active": true
  }
]
```

---

### POST /beats

Create a new beat.

**Request Body:**
```json
{
  "code": "BEAT-002",
  "name": "South Mumbai Route",
  "salesrepUsername": "jane.smith",
  "active": true
}
```

**Success Response (200 OK)**

---

### GET /visits

List visit logs.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `date` | string | ❌ | Specific date (YYYY-MM-DD) | `2025-11-21` |
| `month` | string | ❌ | Month (YYYY-MM) | `2025-11` |
| `outletCode` | string | ❌ | Filter by outlet | `OUT-001` |
| `salesrepUsername` | string | ❌ | Filter by sales rep | `john.doe` |
| `limit` | integer | ❌ | Max results (default: 50) | `100` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "outletCode": "OUT-001",
    "salesrepUsername": "john.doe",
    "visitDate": "2025-11-21T09:30:00Z",
    "checkIn": "2025-11-21T09:30:00Z",
    "checkOut": "2025-11-21T10:15:00Z",
    "notes": "Discussed new products",
    "lat": 19.0760,
    "lon": 72.8777
  }
]
```

---

### POST /visits

Create a visit log.

**Request Body:**
```json
{
  "outletCode": "OUT-001",
  "salesrepUsername": "john.doe",
  "visitDate": "2025-11-21T09:30:00Z",
  "checkIn": "2025-11-21T09:30:00Z",
  "checkOut": "2025-11-21T10:15:00Z",
  "notes": "Productive visit",
  "lat": 19.0760,
  "lon": 72.8777
}
```

**Success Response (200 OK)**

---

### GET /pjp
 
 Get PJP (Permanent Journey Plan) data.
 
 **Query Parameters:**
 | Parameter | Type | Required | Description | Example |
 |-----------|------|----------|-------------|---------|
 | `salesrepUsername` | string | ❌ | Filter by sales rep | `john.doe` |
 | `beatCode` | string | ❌ | Filter by beat | `BEAT-001` |
 | `routeCode` | string | ❌ | Filter by route | `ROUTE-001` |
 | `limit` | integer | ❌ | Max results (default: 50) | `100` |
 | `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |
 
 **Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "salesrep": "john.doe",
    "beatCode": "BEAT-001",
    "routeCode": "ROUTE-001",
    "frequency": "MONTHLY",
    "week1": ["MON", "WED"],
    "week2": ["MON", "WED"],
    "week3": ["MON", "WED"],
    "week4": ["MON", "WED"],
    "week5": ["MON", "WED"],
    "week6": ["MON", "WED"],
    "outlets": [
      { "outletCode": "OUT-001", "sequenceNo": 1 },
      { "outletCode": "OUT-002", "sequenceNo": 2 }
    ]
  }
]
 
 ---
 
 ### GET /pjp/unique-values
 
 Get unique beat and route codes for a sales representative (defaults to logged-in user).
 
 **Query Parameters:**
 | Parameter | Type | Required | Description | Example |
 |-----------|------|----------|-------------|---------|
 | `salesrepUsername` | string | ❌ | Filter by sales rep | `john.doe` |
 
 **Success Response (200 OK):**
 ```json
 {
   "beats": ["BEAT-001", "BEAT-002"],
   "routes": ["ROUTE-001", "ROUTE-002"]
 }
 ```
```

---

### POST /pjp

Create or update PJP.

**Request Body:**
 ```json
  {
    "salesrep": "john.doe",
    "beatCode": "BEAT-001",
    "routeCode": "ROUTE-001",
    "frequency": "MONTHLY",
    "week1": ["TUE", "THU"],
    "week2": ["TUE", "THU"],
    "week3": ["TUE", "THU"],
    "week4": ["TUE", "THU"],
    "week5": ["TUE", "THU"],
    "week6": ["TUE", "THU"],
    "outlets": [
      { "outletCode": "OUT-004", "sequenceNo": 1 },
      { "outletCode": "OUT-005", "sequenceNo": 2 }
    ]
  }
 ```
 
  **Success Response (200 OK)**
 
 ---

### GET /visit-plan/visit-status

Get holistic status of a sales representative for a specific day (Attendance + PJP Completion).

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `salesrep` | string | ✅ | Sales rep username | `john.doe` |
| `date` | string | ❌ | Specific date (YYYY-MM-DD) | `2026-02-02` |

**Success Response (200 OK):**
```json
{
  "salesrepCode": "john.doe",
  "salesrepName": "John Doe",
  "assignedRoute": "Main Market Beat",
  "numberOfOutlets": 10,
  "attendanceStatus": "Present",
  "pjpCompletionStatus": "In Progress"
}
```

---

## 🎯 Targets & KPIs

### GET /kpi/salesrep/daily

Get daily KPIs for a sales rep.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `username` | string | ✅ | Sales rep username | `john.doe` |
| `from` | string | ❌ | Start date (YYYY-MM-DD) | `2025-11-01` |
| `to` | string | ❌ | End date (YYYY-MM-DD) | `2025-11-30` |
| `tz` | string | ❌ | Timezone (default: Asia/Kolkata) | `Asia/Kolkata` |

**Success Response (200 OK):**
```json
{
  "username": "john.doe",
  "from": "2025-11-01",
  "to": "2025-11-30",
  "metrics": {
    "totalOrders": 45,
    "totalRevenue": 125000.00,
    "avgOrderValue": 2777.78,
    "outletsVisited": 38,
    "productiveVisits": 35
  }
}
```

---

### GET /kpi/salesrep/daily/today

Get today's KPIs for a sales rep.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `username` | string | ✅ | Sales rep username | `john.doe` |
| `tz` | string | ❌ | Timezone (default: Asia/Kolkata) | `Asia/Kolkata` |

**Success Response (200 OK):**
```json
{
  "username": "john.doe",
  "date": "2025-11-21",
  "metrics": {
    "ordersToday": 3,
    "revenueToday": 8500.00,
    "visitsToday": 5
  }
}
```

---

### GET /targets

Get sales targets.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `username` | string | ❌ | Filter by sales rep | `john.doe` |
| `period` | string | ❌ | Period (`monthly`, `quarterly`) | `monthly` |

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "username": "john.doe",
    "period": "2025-11",
    "targetRevenue": 150000.00,
    "targetOrders": 50,
    "achievedRevenue": 125000.00,
    "achievedOrders": 45,
    "achievement": 83.33
  }
]
```

---

### POST /targets

Create a sales target.

**Request Body:**
```json
{
  "username": "john.doe",
  "period": "2025-12",
  "targetRevenue": 175000.00,
  "targetOrders": 60
}
```

**Success Response (201 Created)**

---

## 🎮 Gamification & Tasks

### GET /api/tasks

List all tasks.

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "code": "TASK-001",
    "title": "Complete 10 orders",
    "description": "Place 10 orders this week",
    "points": 100,
    "badgeIcon": "🏆",
    "active": true
  }
]
```

---

### PUT /api/tasks

Create or update a task.

**Request Body:**
```json
{
  "code": "TASK-002",
  "title": "Visit 20 outlets",
  "description": "Visit 20 unique outlets this month",
  "points": 200,
  "badgeIcon": "🎯",
  "active": true
}
```

**Success Response (200 OK):**
```json
{
  "id": 2
}
```

---

### DELETE /api/tasks/{code}

Delete a task by code.

**Path Parameters:**
- `code` - Task code

**Success Response (200 OK):**
```json
{
  "deleted": 1
}
```

---

### GET /api/task-activities/{id}

Get a specific task activity.

**Path Parameters:**
- `id` - Activity ID

**Success Response (200 OK):**
```json
{
  "id": 1,
  "taskId": 1,
  "userId": 5,
  "progress": 7,
  "completed": false,
  "completedAt": null
}
```

---

### GET /api/task-activities/task/{taskId}

List activities for a specific task.

**Path Parameters:**
- `taskId` - Task ID

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "taskId": 1,
    "userId": 5,
    "progress": 7,
    "completed": false
  },
  {
    "id": 2,
    "taskId": 1,
    "userId": 6,
    "progress": 10,
    "completed": true,
    "completedAt": "2025-11-20T15:30:00Z"
  }
]
```

---

### PUT /api/task-activities

Create or update a task activity.

**Request Body:**
```json
{
  "taskId": 1,
  "userId": 5,
  "progress": 8
}
```

**Success Response (200 OK):**
```json
{
  "id": 1
}
```

---

### POST /api/task-activities/{id}/done

Mark a task activity as done.

**Path Parameters:**
- `id` - Activity ID

**Success Response (200 OK):**
```json
{
  "updated": 1
}
```

---

### GET /api/user-points

Get user points and leaderboard.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `userId` | integer | ❌ | Filter by user ID | `5` |
| `limit` | integer | ❌ | Max results (default: 50) | `100` |

**Success Response (200 OK):**
```json
[
  {
    "userId": 5,
    "username": "john.doe",
    "totalPoints": 1250,
    "rank": 1,
    "badges": ["🏆", "🎯", "⭐"]
  }
]
```

---

## 🤖 Recommendations (ML)

### GET /recommendations

Get ML-driven product recommendations.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `outletCode` | string | ✅ | Outlet code | `OUT-001` |
| `date` | string | ❌ | Target date (YYYY-MM-DD) | `2025-11-21` |
| `limit` | integer | ❌ | Max results (default: 20) | `50` |

**Success Response (200 OK):**
```json
[
  {
    "sku": "PROD-001",
    "name": "Coca Cola 500ml",
    "recommendedQty": 24,
    "confidence": 0.85,
    "reason": "HISTORICAL_PATTERN",
    "avgWeeklyDemand": 6,
    "lastOrderDate": "2025-11-14"
  }
]
```

---

## 🎁 Promotions

### GET /promotions

List all promotions.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `active` | boolean | ❌ | Filter by active status | `true` |
| `limit` | integer | ❌ | Max results (default: 50) | `100` |

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "code": "PROMO-001",
    "name": "Buy 2 Get 1 Free",
    "description": "Buy 2 cases, get 1 free",
    "startDate": "2025-11-01",
    "endDate": "2025-11-30",
    "active": true,
    "rules": {
      "minQty": 2,
      "freeQty": 1
    }
  }
]
```

---

### POST /promotions

Create a promotion.

**Request Body:**
```json
{
  "code": "PROMO-002",
  "name": "10% Off",
  "description": "10% discount on all beverages",
  "startDate": "2025-12-01",
  "endDate": "2025-12-31",
  "active": true,
  "rules": {
    "discountPercent": 10,
    "categories": ["Beverages"]
  }
}
```

**Success Response (201 Created)**

---

### Order Promo Audit

The Order Promo Audit API provides a detailed audit trail of all promotions applied to orders and order lines.

#### GET /order-promo-audit

List all promotion audit records with optional filtering.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `orderId` | long | ❌ | Filter by order ID | `12345` |
| `promoId` | long | ❌ | Filter by promotion ID | `1` |
| `outletCode` | string | ❌ | Filter by outlet code | `OUT123` |
| `distributorCode` | string | ❌ | Filter by distributor code | `DIST001` |
| `salesrep` | string | ❌ | Filter by salesrep username | `john.doe` |
| `limit` | integer | ❌ | Max results (default: 50) | `100` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "orderId": "12345",
      "type": "ORDER",
      "orderLineId": null,
      "promoId": 1,
      "outletCode": "OUT123",
      "distributorCode": "DIST001",
      "salesrep": "john.doe",
      "discountValue": 100.00,
      "originalValue": 1000.00,
      "createdAt": "2025-11-20T12:00:00Z"
    }
  ],
  "total": 1,
  "limit": 50,
  "offset": 0
}
```

---

#### GET /order-promo-audit/promo/{promoId}

Get audit records for a specific promotion.

**Path Parameters:**
- `promoId` - Promotion ID

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `outletCode` | string | ❌ | Filter by outlet code | `OUT123` |
| `distributorCode` | string | ❌ | Filter by distributor code | `DIST001` |
| `salesrep` | string | string | Filter by salesrep username | `john.doe` |
| `limit` | integer | ❌ | Max results (default: 50) | `100` |
| `offset` | integer | ❌ | Pagination offset (default: 0) | `0` |

**Success Response (200 OK):**
```json
{
  "data": [...],
  "total": 10,
  "limit": 50,
  "offset": 0
}
```

---

## ⚙️ Settings & Configuration

### GET /settings

Get tenant settings.

**Success Response (200 OK):**
```json
{
  "tenantId": "acme_corp",
  "settings": {
    "currency": "INR",
    "timezone": "Asia/Kolkata",
    "orderApprovalRequired": true,
    "minOrderValue": 500.00,
    "features": {
      "gamificationEnabled": true,
      "mlRecommendations": true
    }
  }
}
```

---

### PUT /settings

Update tenant settings.

**Request Body:**
```json
{
  "currency": "INR",
  "timezone": "Asia/Kolkata",
  "orderApprovalRequired": false,
  "minOrderValue": 1000.00
}
```

**Success Response (200 OK)**

---

## 📥 Data Ingestion

### POST /ingest/masters/multipart

Bulk upload master data (products, outlets, users, etc.) via CSV.

**Query Parameters:**
| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `header` | boolean | ❌ | CSV has header row (default: true) | `true` |
| `entity` | string | ✅ | Entity type (`products`, `outlets`, `users`) | `products` |

**Request:**
```bash
curl -X POST 'http://localhost:8080/api/ingest/masters/multipart?header=true&entity=products' \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-Id: acme_corp" \
  -F "file=@products.csv;type=text/csv"
```

**Success Response (200 OK):**
```json
{
  "entity": "products",
  "processed": 500,
  "inserted": 480,
  "updated": 20,
  "errors": 0,
  "errorDetails": []
}
```

---

## 🔄 Common Patterns

### Pagination

Most list endpoints support pagination via `limit` and `offset` parameters:

```bash
# Get first 50 results
GET /products?limit=50&offset=0

# Get next 50 results
GET /products?limit=50&offset=50
```

### Search/Filtering

Many endpoints support a `q` parameter for text search:

```bash
# Search products by name
GET /products?q=cola

# Search outlets by name or code
GET /outlets?q=sharma
```

### Date Filtering

Date parameters typically accept ISO 8601 format:

```bash
# Filter orders by date range
GET /orders?from=2025-11-01T00:00:00Z&to=2025-11-30T23:59:59Z

# Filter by date only
GET /visits?date=2025-11-21
```

### Expanding Related Data

Some endpoints support `expand` parameter to include related data:

```bash
# Get order with line items
GET /orders/123?expand=lines

# Get all related data
GET /orders/123?expand=all
```

---

## ⚠️ Error Handling

### Standard Error Response Format

```json
{
  "error": "error_code",
  "message": "Human-readable error message"
}
```

### Common HTTP Status Codes

| Status Code | Meaning | When Used |
|-------------|---------|-----------|
| `200 OK` | Success | Successful GET, PUT, PATCH requests |
| `201 Created` | Resource created | Successful POST requests |
| `204 No Content` | Success with no body | Successful DELETE requests |
| `400 Bad Request` | Invalid input | Missing required fields, validation errors |
| `401 Unauthorized` | Authentication failed | Invalid or missing JWT token |
| `403 Forbidden` | Access denied | RLS policy violation, insufficient permissions |
| `404 Not Found` | Resource not found | Requested resource doesn't exist |
| `409 Conflict` | Duplicate resource | Unique constraint violation |
| `500 Internal Server Error` | Server error | Unexpected server-side errors |

### Example Error Responses

**400 Bad Request:**
```json
{
  "error": "validation_error",
  "message": "sku and name are required"
}
```

**401 Unauthorized:**
```json
{
  "error": "unauthorized",
  "message": "Invalid or expired token"
}
```

**409 Conflict:**
```json
{
  "error": "duplicate_sku",
  "message": "SKU already exists"
}
```

---

## 💡 Best Practices

### 1. Always Include Tenant Context

```http
X-Tenant-Id: acme_corp
```

All requests must include the tenant ID header for proper data isolation.

### 2. Use Pagination for Large Datasets

```bash
# Good: Paginated request
GET /products?limit=100&offset=0

# Avoid: Fetching all records at once
GET /products
```

### 3. Leverage Search Parameters

```bash
# Efficient: Search with filters
GET /outlets?q=mumbai&channel=RETAIL&limit=25

# Less efficient: Fetch all and filter client-side
GET /outlets
```

### 4. Use Appropriate HTTP Methods

- `GET` - Retrieve data (idempotent, cacheable)
- `POST` - Create new resources
- `PUT` - Update entire resource
- `PATCH` - Partial update
- `DELETE` - Remove resource

### 5. Handle Errors Gracefully

```javascript
try {
  const response = await fetch('/api/orders', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      'X-Tenant-Id': tenantId
    },
    body: JSON.stringify(orderData)
  });
  
  if (!response.ok) {
    const error = await response.json();
    console.error('Order creation failed:', error.message);
    // Handle specific error codes
    if (error.error === 'duplicate_code') {
      // Show user-friendly message
    }
  }
} catch (err) {
  console.error('Network error:', err);
}
```

### 6. Optimize Catalog Queries

```bash
# Good: Specific outlet and date
GET /catalog?outlet_code=OUT-001&as_of=2025-11-21&limit=50

# Better: Include search to reduce results
GET /catalog?outlet_code=OUT-001&q=beverages&limit=20
```

### 7. Use Expand Wisely

```bash
# Only expand when needed
GET /orders/123?expand=lines

# Avoid expanding on list endpoints (performance impact)
GET /orders?expand=lines  # ❌ Avoid
```

### 8. Batch Operations

For bulk operations, use dedicated batch endpoints:

```bash
# Good: Use bulk upload
POST /ingest/masters/multipart

# Avoid: Multiple individual requests
POST /products  # repeated 500 times ❌
```

---

## 📊 API Summary

### Modules Overview

| Module | Endpoints | Primary Function | Key Features |
|--------|-----------|------------------|--------------|
| **Auth** | 2 | Authentication & Registration | JWT tokens, tenant creation |
| **Users** | 4 | User Management | CRUD operations, org mapping |
| **Org Hierarchy** | 5 | Organization Structure | Multi-level hierarchies, territories |
| **Org Location** | 10 | Geographic Hierarchies | Geo-fencing, territory mapping |
| **Distributors** | 3 | Distributor Management | Location data, user assignment |
| **Outlets** | 4 | Outlet Management | Retail locations, channel mapping |
| **Products** | 7 | Product Management | SKU-based, inventory tracking |
| **Catalog** | 2 | Pricing & Entitlements | Dynamic pricing, sell rights |
| **Orders** | 9 | Order Processing | Multi-line orders, status workflow |
| **Sales** | 2 | Sales Data Ingestion | CSV upload, bulk processing |
| **PJP** | 6 | Field Force Automation | Beats, visits, journey plans |
| **KPIs** | 2 | Performance Tracking | Daily metrics, achievements |
| **Targets** | 2 | Goal Management | Revenue targets, tracking |
| **Tasks** | 6 | Gamification | Points, badges, leaderboards |
| **Recommendations** | 1 | ML Predictions | Smart order suggestions |
| **Promotions** | 2 | Campaign Management | Discounts, offers |
| **Settings** | 2 | Configuration | Tenant preferences |
| **Ingestion** | 1 | Bulk Data Upload | Master data import |
| **Tax** | 4 | Tax Management | Rule-based tax, SKU fallbacks |

**Total Endpoints:** 70+

---

## 🧾 Tax Management

The Tax Management API allows organizations to define tax rules at global or SKU-specific levels.

[View Tax API Documentation](TAX_API.md)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/tax-rules` | List all tax rules |
| `POST` | `/tax-rules` | Create/Update a tax rule |
| `DELETE` | `/tax-rules/{id}` | Remove a tax rule |
| `GET` | `/tax-rules/effective` | Resolve effective tax for SKU |

---

## 🔗 Additional Resources

- [REST API Best Practices](https://restfulapi.net/)
- [JWT Authentication Standards](https://tools.ietf.org/html/rfc8725)
- [OpenAPI Specification](https://swagger.io/specification/)
- [HTTP Status Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)

---

## 📝 Changelog

### Version 1.1 (2025-11-21)
- Added Organization Hierarchy APIs
- Added Organization Location & Geography APIs
- Added Distributor Management APIs
- Expanded to 70+ endpoints across 18 modules
- Enhanced documentation with use cases and examples

### Version 1.0 (2025-11-21)
- Initial Platform API documentation
- 15 modules documented
- 52+ endpoints with detailed specifications
- Authentication and authorization flows
- Code examples and best practices

---

**© 2025 Salescodeai. All rights reserved.**
