# Outlet Mapping API Documentation

This document describes the API endpoints for Outlet Mapping, Unification, and Code Change operations. These APIs allow for managing duplicate outlets, merging them, and renaming outlets while preserving data integrity.

## Base URL
`/outlet-mapping`

## Authentication
All endpoints require standard authentication headers (e.g., `X-Tenant-Id`, `Authorization`).

---

## 1. Find Matches (Suggest Merges)

Finds potential duplicate outlets or merge candidates for a specific outlet. Matches are found using:
1.  **Phone Number**: Precise match on phone number (Perfect Match).
2.  **Name & Location**: Outlets within **100 meters** AND **>70% Name Similarity**.
 
**Note:** Outlets with `mappedStatus` as "MAPPED" are automatically excluded from the list of suggestions.

*   **Endpoint:** `/matches/{outletCode}`
*   **Method:** `GET`
*   **Path Parameters:**
    *   `outletCode` (String): The code of the outlet to find matches for.

### Response
Returns a JSON array of matching outlet objects.

**Status Code:** `200 OK`

**Response Body:**
```json
[
  {
    "outletCode": "OUTLET_B_123",
    "outletName": "Outlet B Target",
    "pincode": "110001",
    "matchReason": "PHONE" 
  },
  {
    "outletCode": "OUTLET_C_456",
    "outletName": "Another Match",
    "pincode": "110001",
    "matchReason": "NAME_AND_LOCATION"
  }
]
```
*   `matchReason`: Indicates why this outlet was suggested (e.g., "PHONE" or "NAME_AND_LOCATION").

---

## 2. Unify Outlets (Merge)
 
Merges a source outlet into a target outlet. This operation moves related data (such as Orders, Retailer Mappings) from the source to the target. The source outlet is **marked as "MAPPED"** (not deleted) and its `mappedBy` field is set to the current user's username. Outlets already marked as MAPPED cannot be unified again.
 
*   **Endpoint:** `/unify`
*   **Method:** `POST`
 
### Request Body
```json
{
  "sourceOutletCode": "OUTLET_A_SOURCE",
  "targetOutletCode": "OUTLET_B_TARGET"
}
```
*   `sourceOutletCode` (Required): The code of the outlet involved in the merge that will be marked as mapped.
*   `targetOutletCode` (Required): The code of the outlet that will receive the data and remain active.
 
### Response
 
**Success (200 OK):**
```json
{
  "status": "SUCCESS",
  "message": "Unified OUTLET_A_SOURCE into OUTLET_B_TARGET"
}
```
 
**Client Error (400 Bad Request):**
```json
{
  "error": "Source and Target codes required"
}
```
 
**Server Error (500 Internal Server Error):**
```json
{
  "error": "Detailed error message..."
}
```
 
---
 
## 3. Change Outlet Code (Rename)
 
Renames an outlet by changing its code from `currentCode` to `newCode`. 
This operation follows a **Clone-Move-Map** pattern:
1.  **Clone**: A new outlet record is created with `newCode`, copying attributes from the old outlet.
2.  **Move**: All associated data (Orders, Mappings, etc.) is moved to the `newCode`.
3.  **Map**: The old outlet (`currentCode`) is **marked as "MAPPED"** and its `mappedBy` field is set.
 
This endpoint also allows updating the outlet's attributes (like name, phone, address) during the rename process.
 
*   **Endpoint:** `/change-code`
*   **Method:** `POST`
 
### Request Body
 
```json
{
  "currentCode": "OLD_CODE_123",
  "newCode": "NEW_CODE_456",
  "outletDetails": {
    "name": "Updated Outlet Name",
    "phone": "9876543210",
    "channel": "GT",
    "address": "123 New Street",
    "pincode": "110001",
    "lat": 28.7041,
    "lon": 77.1025,
    "extendedAttr": {
      "key": "value"
    },
    "location": {
      "territory": "NORTH"
    },
    "tags": ["verified", "premium"],
    "orgLocationCode": "ORG_LOC_001"
  }
}
```
 
*   `currentCode` (Required): The existing code of the outlet.
*   `newCode` (Required): The new code to assign to the outlet.
*   `outletDetails` (Optional): An object containing attributes to update for the outlet. This uses the standard `CreateOutletRequest` structure. Key fields include:
    *   `name`
    *   `phone`, `address`, `pincode`
    *   `lat`, `lon`
    *   `channel`
    *   `extendedAttr` (Map)
    *   `location` (Map)
    *   `tags` (List)
 
### Response
 
**Success (200 OK):**
```json
{
  "status": "SUCCESS",
  "message": "Changed code from OLD_CODE_123 to NEW_CODE_456"
}
```

**Client Error (400 Bad Request):**
```json
{
  "error": "currentCode and newCode required"
}
```

**Server Error (500 Internal Server Error):**
```json
{
  "error": "Detailed error message..."
}
```
