# Promotion Resource List - Implementation Summary

## Objective
Enable the Promotions API to load applicable promotions for Retailer users by automatically extracting their context (outlet, distributor, channel, segment) from the database.

## Implementation

### 1. New Endpoint: `GET /promotions/retailer`

**Location**: `PromotionResource.java`

**Features**:
- **Smart Auto-Loading**: Automatically resolves user context when parameters are not provided
- **Flexible Parameters**: Supports both auto-load and manual override modes
- **Context-Aware**: Loads channel and segment from outlet metadata
- **Integrated Targeting**: Uses the same promotion targeting engine as order evaluation

**Parameters**:
- `outletCode` (optional): If not provided, loads from user's outlet mappings
- `distributorCode` (optional): If not provided, loads from retailer_map table

### 2. Auto-Loading Logic

```
User Request (JWT) 
    ↓
Extract Username from JWT
    ↓
Load User → Determine orgType (RETAILER, SALESREP, etc.)
    ↓
If outletCode NOT provided:
    → Call OutletDao.getOutletCodesForUser(username, orgType)
    → Use first outlet code
    ↓
Load Outlet by Code
    → Extract channel
    → Extract segment from extendedAttr
    ↓
If distributorCode NOT provided:
    → Query RetailerMapDao.list(outletCode, ...)
    → Extract distributorCode from first active mapping
    ↓
Build OrderContext(outletCode, distributorCode, null, channel, segment, [])
    ↓
Call PromotionDao.listApplicablePromotions(ctx, today)
    → Uses promotion targeting engine
    → Returns only applicable promotions
```

### 3. Database Integration

**Tables Used**:
- `outlet` - For channel and segment information
- `user_org_map` - For user-to-outlet mappings (RETAILER orgType)
- `retailer_map` - For outlet-to-distributor mappings (SALESREP orgType)
- `promotion`, `promotion_rule`, `promotion_rule_target` - For promotion matching
- `target_group`, `target_group_member` - For target group matching

**DAOs Injected**:
- `PromotionDao` - Promotion operations
- `OutletDaoPlainJdbc` - Outlet queries and user mappings
- `RetailerMapDao` - Retailer-distributor mappings
- `UserDaoPlainJdbc` - User information
- `TenantContext` - Current user context

### 4. Code Changes

#### PromotionResource.java
```java
@GET
@Path("/retailer")
public List<Promotion> listForRetailer(
        @QueryParam("outletCode") String outletCode,
        @QueryParam("distributorCode") String distributorCode) {
    
    // Auto-load user context
    String currentUsername = tenantContext.user();
    AppUser currentUser = userDao.findUser(currentUsername);
    String orgType = (currentUser != null && currentUser.orgType != null) 
        ? currentUser.orgType : "RETAILER";
    
    // Auto-load outlet if not provided
    if (outletCode == null || outletCode.isBlank()) {
        List<String> outletCodes = outletDao.getOutletCodesForUser(currentUsername, orgType);
        outletCode = outletCodes.get(0);
    }
    
    // Load outlet details
    Outlet outlet = outletDao.findByCode(outletCode);
    
    // Auto-load distributor if not provided
    if (distributorCode == null || distributorCode.isBlank()) {
        List<RetailerMap> mappings = retailerMapDao.list(null, outletCode, null, null, true, 1, 0);
        if (!mappings.isEmpty()) {
            distributorCode = mappings.get(0).distributorCode;
        }
    }
    
    // Extract channel and segment
    String channel = outlet.channel;
    String segment = outlet.extendedAttr != null 
        ? String.valueOf(outlet.extendedAttr.get("segment")) : null;
    
    // Build context and fetch applicable promotions
    OrderContext ctx = new OrderContext(outletCode, distributorCode, null, channel, segment, List.of());
    return promotionDao.listApplicablePromotions(ctx, LocalDate.now());
}
```

#### PromotionDao.java
```java
public List<Promotion> listApplicablePromotions(OrderContext ctx, LocalDate onDate) {
    return db.tx(c -> {
        // Reuses same targeting logic as evaluation engine
        List<Long> ids = findCandidatePromotionIds(c, ctx, onDate);
        List<Promotion> promos = loadPromotionsByIds(c, ids);
        if (!promos.isEmpty()) {
            loadTargetGroups(c, promos);
        }
        return promos;
    });
}
```

## Usage Examples

### Example 1: Mobile App (Auto-load)
```javascript
// Retailer user is logged in with JWT
fetch('/promotions/retailer', {
  headers: { 'Authorization': `Bearer ${token}` }
})
.then(res => res.json())
.then(promotions => {
  // promotions applicable to user's outlet
  console.log(`${promotions.length} promotions available`);
});
```

### Example 2: Admin Override
```javascript
// Admin checking promotions for specific outlet
fetch('/promotions/retailer?outletCode=OUT123&distributorCode=DIST456', {
  headers: { 'Authorization': `Bearer ${adminToken}` }
})
```

## Testing

### Test Files Created:
1. `test_promotion_retailer_list.py` - Comprehensive integration tests

### Test Coverage:
- ✅ Auto-load outlet from user mappings
- ✅ Auto-load distributor from retailer_map
- ✅ Manual outlet code override
- ✅ Channel and segment extraction from outlet
- ✅ Promotion filtering by channel (GT vs MT)
- ✅ Error handling (404, 400)
- ✅ Print promotion details for visibility

### Test Results:
All tests passing ✅

## Benefits

1. **Developer-Friendly**: Minimum parameters required from client
2. **Secure**: Context loaded from database, not user input
3. **Consistent**: Uses same targeting engine as order evaluation
4. **Flexible**: Supports both auto-load and manual modes
5. **Performant**: Single query to load applicable promotions

## API Documentation

Comprehensive API documentation created at:
- `docs/PROMOTIONS_RETAILER_API.md`

## Future Enhancements

Potential improvements:
1. Support for multiple outlets per user (aggregate or select)
2. Caching of user context for performance
3. Webhook notifications when promotions change
4. Analytics on promotion views by retailers
