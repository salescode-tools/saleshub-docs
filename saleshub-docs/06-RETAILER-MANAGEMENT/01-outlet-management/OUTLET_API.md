# Outlet API Reference

The Outlet API provides comprehensive management of retail outlets, including creation, retrieval, tagging, and complex organizational associations.

---

## 📋 Table of Contents
- [List Outlets](#list-outlets)
- [Get Outlet Details](#get-outlet-details)
- [Outlet Associations (Tree View)](#outlet-associations-tree-view)
- [Create Outlet](#create-outlet)
- [Update Outlet](#update-outlet)
- [Patch Tags](#patch-tags)
- [Get Unique Tags](#get-unique-tags)
- [Get Unique Values](#get-unique-values)
- [Delete Outlet](#delete-outlet)
- [Utility APIs](#utility-apis)
  - [Get Contacts](#get-contacts)
  - [Get SalesReps](#get-salesreps)
  - [Get Distributors](#get-distributors)
  - [Get Retailer Mappings](#get-retailer-mappings)

---

## List Outlets

Retrieve a list of outlets based on search criteria and user context.

**Endpoint:** `GET /outlets`

### Query Parameters
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `q` | `string` | No | Search query for name or code. |
| `channel` | `string` | No | Filter by sales channel (e.g., GT, MT). |
| `location` | `string` | No | Filter by location code (hierarchical search). |
| `retailerUser` | `string` | No | Resolve outlets for a specific user context. |
| `tags` | `array` | No | Filter by one or more tags. |
| `outletType` | `string` | No | Filter by outlet type (e.g., Retail, Wholesale). |
| `outletCategory` | `string` | No | Filter by outlet category (e.g., Premium, Standard). |
| `outletClass` | `string` | No | Filter by outlet class (e.g., Class A, Diamond). |
| `city` | `string` | No | Filter by city. |
| `state` | `string` | No | Filter by state. |
| `hierarchical` | `boolean` | No | Aggregate results from all child tenants (default: **true**). |
| `limit` | `int` | No | Pagination limit (default: 25). |
| `offset` | `int` | No | Pagination offset (default: 0). |

**Note on Hierarchical Mode:**
By default, `GET /outlets` returns a consolidated list of outlets from the parent and all direct child tenants. Each outlet object includes its source `tenant_id`. To restrict the search to just the current tenant, set `hierarchical=false`.


---

## Get Outlet Details

Retrieve detailed information about a specific outlet, including mapped users and location data.

**Endpoint:** `GET /outlets/{outletId}`

### Response Objects
Includes associated `users` array and organizational location codes.

---

## Outlet Associations (Tree View)

Returns a hierarchical view of the relationships between **Outlets**, their assigned **SalesReps**, and the corresponding **Distributors**.

**Endpoint:** `GET /outlets/associations`

### Query Parameters
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `retailerUser` | `string` | No | Resolve tree for a specific user. Defaults to auth user. |

### Response Structure (Full Tree)
```json
[
  {
    "outlet": { "code": "OUT_001", "name": "Kiran Store", ... },
    "distributors": [
      { "code": "DIST_01", "name": "Main Distributor" }
    ],
    "salesreps": [
      {
        "salesrep": { "username": "SR_ALICE", ... },
        "distributors": [
          { "code": "DIST_01", "name": "Main Distributor" }
        ]
      }
    ]
  }
]
```

### Response Structure (Outlet & Distributor only)
This sample shows the response when only direct outlet-distributor associations are relevant.
```json
[
  {
    "outlet": { "code": "OUT_002", "name": "City Mall Outlet", ... },
    "distributors": [
      { "code": "DIST_01", "name": "Main Distributor" },
      { "code": "DIST_02", "name": "Secondary Dist" }
    ],
    "salesreps": []
  }
]
```

---

## Create Outlet

Create a new outlet and optionally link/create users.

**Endpoint:** `POST /outlets`

### Request Body (`CreateOutletRequest`)
| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `code` | `string` | Yes | Unique outlet identifier. |
| `name` | `string` | Yes | Display name. |
| `channel` | `string` | No | Sales channel. |
| `users` | `array` | No | List of users to create/link to this outlet. |
| `address` | `string` | No | Full address. |
| `phone` | `string` | No | Contact phone number. |
| `email` | `string` | No | Contact email address. |
| `pincode` | `string` | No | Postal code. |
| `active` | `boolean` | No | Whether the outlet is active (default: **true**). |
| `lat` | `number` | No | Latitude. |
| `lon` | `number` | No | Longitude. |
| `tags` | `array` | No | List of tags. |
| `outletType` | `string` | No | Type of outlet. |
| `outletCategory` | `string` | No | Categorization of outlet. |
| `outletClass` | `string` | No | Class/Grade of outlet (e.g., Platinum, Class A). |
| `outletDivision` | `string` | No | Business division of the outlet. |
| `routeCode` | `string` | No | Assigned beat or route code. |
| `subChannel` | `string` | No | More granular channel info. |
| `city` | `string` | No | City name. |
| `state` | `string` | No | State/Province. |
| `country` | `string` | No | Country name. |
| `location` | `map` | No | Hierarchical location map (e.g. `{"STATE": "MH", "CITY": "PUNE"}`). |
| `orgLocationCode` | `string` | No | Management location code (Fallback if `location` map not provided). |

#### 📍 Hierarchical Location Creation
Outlets support an advanced **Hierarchical Location** facility during creation and registration. This allows you to associate an outlet with a specific geographical level while ensuring the system maintains parent-child relationships.

**Key Features:**
- **Lowest Level Association**: The outlet is automatically mapped to the most granular level provided in the map.
- **Auto-Creation**: If a location code provided in the map does not exist, the system **automatically creates it** and links it to the parent level provided in the same map.
- **Hierarchy Awareness**: It uses the system's `org_location_def` to ensure levels are processed in the right order (e.g., State → District → City).

**Example: Auto-Creating a City while creating an Outlet**
```json
{
  "code": "OUT_0099",
  "name": "New City Outlet",
  "channel": "RETAIL",
  "address": "123 New St",
  "phone": "9876543210",
  "email": "contact@store.com",
  "pincode": "560001",
  "active": true,
  "outletDivision": "FMCG",
  "routeCode": "BEAT_01",
  "location": {
    "STATE": "KARNATAKA", 
    "CITY": "BENGALURU_NORTH" 
  }
}
```
*In this example: If "KARNATAKA" exists but "BENGALURU_NORTH" doesn't, the system will create the city, set its parent to Karnataka, and associate the outlet with the city.*

---


---

## Update Outlet

Update existing outlet details and user mappings.

**Endpoint:** `PUT /outlets/{outletId}`
 
*Note: Providing the `tags` array in this request will replace all existing tags for the outlet. Individual tags can be managed using the PATCH endpoint below.*

---

## Patch Tags

Add or remove tags from an outlet without modifying other data.

**Endpoint:** `PATCH /outlets/{outletId}/tags`

### Request Body
```json
{
  "addTags": ["VIP", "FAST_MOVING"],
  "removeTags": ["OLD_TAG"]
}
```

---

## Get Unique Tags

Retrieve a sorted list of all unique tags currently associated with any outlet in the current tenant.

**Endpoint:** `GET /outlets/tags`

### Response
Returns a JSON array of strings:
```json
["Chain", "Premium", "Retail", "VIP"]
```

---

## Get Unique Values

Retrieve a list of all distinct values currently existing in the database for various outlet attributes.

**Endpoint:** `GET /outlets/unique-values`

### Response Structure
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

## Delete Outlet

Remove an outlet mapping from the system.

**Endpoint:** `DELETE /outlets/{outletId}`

---

## Utility APIs

### Get Contacts
Retrieve a list of retailer users directly mapped to the outlet.

**Endpoint:** `GET /outlets/{code}/contacts`

---

### Get SalesReps
Retrieve a list of Sales Representatives assigned to this outlet via retailer mappings.

**Endpoint:** `GET /outlets/{code}/salesreps`

---

### Get Distributors
Retrieve a list of Distributors serving this outlet.

**Endpoint:** `GET /outlets/{code}/distributors`

---

### Get Retailer Mappings
Retrieve the raw mapping data linking this outlet to its various distributors and sales representatives.

**Endpoint:** `GET /outlets/{code}/retailer-maps`

**Query Parameters:**
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `salesrep` | `string` | No | Filter by sales coordinator/representative username. |
| `distributor` | `string` | No | Filter by distributor code. |

> **Tip**: For bulk creation, search, or full-sync of mappings across multiple outlets, use the [Retailer Mapping API](./RETAILER_MAP_API.md).

---

## Role-Based Visibility
- **Admin**: Full access to all outlets and associations.
- **SalesRep**: Can only see outlets within their assigned "Beat". 
- **Retailer**: Can only see outlets they are explicitly mapped to.
