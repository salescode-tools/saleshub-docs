# Serviceability API Documentation

The Serviceability API allows clients to check if a specific location (pincode or coordinates) is serviceable by identifying available distributors across the tenant hierarchy.

## Endpoints

### Check Serviceability
`POST /serviceability`

Checks for available distributors in a given area. It searches through the current tenant and all child tenants.

#### Request Body
The request accepts either a pincode or latitude/longitude coordinates. If both are provided, pincode takes priority. If neither is provided, the API attempts to use the logged-in user's profile location.

| Field | Type | Description |
| :--- | :--- | :--- |
| `pincode` | `string` | optional. The 6-digit pincode to check. |
| `lat` | `number` | optional. Latitude of the location. |
| `lon` | `number` | optional. Longitude of the location. |
| `radiusKm` | `number` | optional. Search radius in kilometers. Defaults to system setting `distributor_search_radius_km` (or 5km). |

**Example Request (Lat/Lon):**
```json
{
  "lat": 12.9716,
  "lon": 77.5946,
  "radiusKm": 10.0
}
```

**Example Request (Pincode):**
```json
{
  "pincode": "560001"
}
```

#### Response Body
Returns a status indicating if the area is serviceable and a list of available distributors grouped by tenant.

| Field | Type | Description |
| :--- | :--- | :--- |
| `serviceable` | `boolean` | `true` if at least one distributor is found. |
| `associatedOutletCode` | `string` | The code of the outlet associated with the user (only for `RETAILER` or `SALESREP`). |
| `services` | `array` | List of service information per tenant. |

**`services` item structure:**
| Field | Type | Description |
| :--- | :--- | :--- |
| `tenantId` | `string` | The ID of the tenant where distributors were found. |
| `distributors` | `array` | List of distributor information. |

**`distributor` item structure:**
| Field | Type | Description |
| :--- | :--- | :--- |
| `code` | `string` | Unique distributor code. |
| `name` | `string` | Distributor name. |
| `pincode` | `string` | Distributor pincode. |
| `distance` | `number` | Distance from the requested location (only populated for geo-searches). |

**Example Response:**
```json
{
  "serviceable": true,
  "associatedOutletCode": "OUT-001",
  "services": [
    {
      "tenantId": "parent_tenant",
      "distributors": [
        {
          "code": "DIST001",
          "name": "Central Electronics",
          "pincode": "560001",
          "distance": 1.2
        }
      ]
    }
  ]
}
```

## Logic & Rules

1. **Hierarchy Search**: The API automatically queries the current tenant and all its child tenants.
2. **Search Priority**:
   - If `pincode` is provided, it searches for distributors with a matching pincode.
   - If no pincode matches are found (or no pincode was provided), it performs a geo-spatial search based on `lat` and `lon` within the specified `radiusKm`.
3. **Fallback**: If the request body is empty or lacks location data, the API fetches the `lat`, `lon`, and `pincode` from the logged-in user's profile.
4. **User Association**: If the logged-in user has an `orgType` of `RETAILER` or `SALESREP`, the API identifies their primary associated outlet and returns its code in `associatedOutletCode`.
