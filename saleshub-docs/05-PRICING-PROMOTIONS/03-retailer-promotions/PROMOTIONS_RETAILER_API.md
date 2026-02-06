# Promotions API - Retailer Listing

## Overview

The Promotions API provides a specialized endpoint `/promotions/retailer` for listing promotions applicable to retailer users. This endpoint automatically loads the user's context (outlet, distributor, channel, segment) to return only relevant promotions.

## Endpoint

```
GET /promotions/retailer
```

## Authentication

Requires valid JWT token with retailer user credentials.

## Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `outletCode` | String | No | Outlet code. If not provided, automatically loaded from user's outlet mappings |
| `distributorCode` | String | No | Distributor code. If not provided, automatically lookup from retailer_map |

## Auto-Loading Behavior

### When NO parameters are provided:

1. **User Detection**: Extracts current user from JWT token
2. **Outlet Loading**: Calls `OutletDao.getOutletCodesForUser(username, orgType)` to get user's outlet codes
3. **Outlet Selection**: Uses the first outlet code from the list
4. **Distributor Loading**: Queries `retailer_map` table to find the distributor associated with the outlet
5. **Context Extraction**: Loads channel and segment from the outlet record
6. **Promotion Matching**: Returns promotions matching the complete context

### When PARTIAL parameters are provided:

- If `outletCode` is provided: Uses it directly
- If `outletCode` is NOT provided: Auto-loads from user mappings
- If `distributorCode` is provided: Uses it directly  
- If `distributorCode` is NOT provided: Auto-loads from retailer_map

## Response

Returns an array of `Promotion` objects that match the retailer's context.

```json
[
  {
    "id": 123,
    "code": "PROMO_GT_2024",
    "name": "GT Channel Promotion",
    "kind": "SLAB_SCHEME",
    "status": "ACTIVE",
    "priority": 100,
    "stackable": true,
    ...
  }
]
```

## Examples

### Example 1: Auto-load everything (Recommended for Retailer Apps)

```bash
# As a logged-in retailer user
GET /promotions/retailer
Authorization: Bearer <retailer_jwt_token>
```

**Behavior**:
- Outlet code: Auto-loaded from user's mapping
- Distributor code: Auto-loaded from retailer_map
- Channel: Auto-loaded from outlet
- Segment: Auto-loaded from outlet.extendedAttr

### Example 2: Specify outlet explicitly

```bash
GET /promotions/retailer?outletCode=OUT123
Authorization: Bearer <retailer_jwt_token>
```

**Behavior**:
- Outlet code: OUT123 (provided)
- Distributor code: Auto-loaded from retailer_map for OUT123
- Channel: Auto-loaded from OUT123
- Segment: Auto-loaded from OUT123

### Example 3: Specify both outlet and distributor

```bash
GET /promotions/retailer?outletCode=OUT123&distributorCode=DIST456
Authorization: Bearer <retailer_jwt_token>
```

**Behavior**:
- All parameters are explicitly provided
- Still loads channel and segment from outlet

## Error Responses

### 400 Bad Request
- User context not found (invalid/missing JWT)

### 404 Not Found
- No outlets found for the user
- Specified outlet code doesn't exist

## Use Cases

### Mobile App for Retailers
```javascript
// Simply call the endpoint - everything is auto-loaded
fetch('/promotions/retailer', {
  headers: { 'Authorization': `Bearer ${userToken}` }
})
```

### Admin Testing a Specific Outlet
```javascript
// Override with specific outlet for testing
fetch('/promotions/retailer?outletCode=OUT123', {
  headers: { 'Authorization': `Bearer ${adminToken}` }
})
```

## Implementation Details

The endpoint uses the same promotion targeting logic as the Order evaluation engine:
- Checks `promotion_rule_target` for outlet/channel/segment matching
- Supports `target_group` membership checking
- Respects promotion status (ACTIVE) and date ranges
- Returns promotions ordered by priority

## Related Endpoints

- `GET /promotions` - List all promotions (with optional filters)
- `POST /promotions/evaluate` - Evaluate promotions for a specific order
- `GET /promotions/{id}` - Get promotion details

## Database Tables Used

- `promotion` - Main promotion records
- `promotion_rule` - Promotion rules
- `promotion_rule_target` - Targeting criteria
- `outlet` - Outlet information (channel, segment)
- `retailer_map` - Outlet-to-distributor mappings
- `user_org_map` - User-to-outlet mappings
- `target_group` - Target group definitions
- `target_group_member` - Target group members
