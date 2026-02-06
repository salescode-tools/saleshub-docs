# Promotion Targeting: Two Approaches

This document explains the two ways to target promotions in the Sales Lite system.

## Overview

The promotion system supports **two complementary approaches** for targeting:

1. **Target Groups** - Flexible, reusable customer segments
2. **Rule Targets** - Direct, inline targeting specifications

Both approaches can be used independently or together, giving you maximum flexibility.

---

## Approach 1: Target Groups (Recommended for Complex Scenarios)

### When to Use
- When you need to reuse the same customer segment across multiple promotions
- When targeting logic is complex (e.g., "All GT outlets in Mumbai except 5 specific ones")
- When you want to manage customer segments independently from promotions
- When you need heterogeneous targeting (mix of outlets, distributors, salesreps in one group)

### Example Payload

```json
{
  "promotion": {
    "code": "PROMO_TG_001",
    "name": "Premium Outlets Promotion",
    "kind": "SLAB_SCHEME",
    "status": "ACTIVE",
    "priority": 100,
    "stackable": true
  },
  "rules": [
    {
      "scope": "ITEM",
      "targets": [],
      "targetGroupIds": [24, 25],  // Reference to existing target groups
      "filters": [
        { "scope": "ORDER_LINE", "field": "sku", "op": "IN", "values": ["SKU001"] }
      ],
      "conditions": [
        { "basis": "LINE_QTY", "slabIndex": 0, "minValue": 10 }
      ],
      "benefits": [
        { "scope": "ORDER_LINE", "type": "FREE_GOODS", "slabIndex": 0, "freeSku": "SKU_FREE", "freeQty": 1 }
      ]
    }
  ]
}
```

### Creating a Target Group First

```json
POST /target-groups

{
  "name": "Premium GT Outlets",
  "description": "High-value GT channel outlets",
  "isActive": true,
  "members": [
    {
      "targetType": "OUTLET",
      "selectionMode": "SPECIFIC",
      "entityCode": "OUT001",
      "isExcluded": false
    },
    {
      "targetType": "CHANNEL",
      "selectionMode": "SPECIFIC",
      "entityCode": "GT",
      "isExcluded": false
    }
  ]
}
```

### Advantages
- ✅ Reusable across multiple promotions
- ✅ Can be managed independently (add/remove members without touching promotions)
- ✅ Supports complex inclusion/exclusion logic
- ✅ Supports heterogeneous member types (outlets + distributors + salesreps in one group)
- ✅ Better for large-scale targeting

---

## Approach 2: Rule Targets (Recommended for Simple Scenarios)

### When to Use
- When targeting is simple and promotion-specific
- When you don't need to reuse the targeting logic
- When you want everything in one payload (no separate API calls)
- For quick, one-off promotions

### Example Payload

```json
{
  "promotion": {
    "code": "PROMO_RT_001",
    "name": "GT Channel Promotion",
    "kind": "SLAB_SCHEME",
    "status": "ACTIVE",
    "priority": 100,
    "stackable": true
  },
  "rules": [
    {
      "scope": "ITEM",
      "targets": [
        {
          "outletCode": "OUT001",           // Specific outlet
          "channel": "GT",                   // Specific channel
          "matchAllDistributors": false,
          "matchAllOutlets": false,
          "matchAllSalesreps": true,         // Any salesrep
          "matchAllChannels": false,
          "matchAllSegments": true           // Any segment
        }
      ],
      "filters": [
        { "scope": "ORDER_LINE", "field": "sku", "op": "IN", "values": ["SKU001"] }
      ],
      "conditions": [
        { "basis": "LINE_QTY", "slabIndex": 0, "minValue": 5 }
      ],
      "benefits": [
        { "scope": "ORDER_LINE", "type": "PERCENT_DISCOUNT", "slabIndex": 0, "percentOff": 10 }
      ]
    }
  ]
}
```

### Match-All Example (Global Promotion)

```json
{
  "promotion": {
    "code": "PROMO_ALL_001",
    "name": "Sitewide Promotion",
    "kind": "SLAB_SCHEME",
    "status": "ACTIVE",
    "priority": 100,
    "stackable": true
  },
  "rules": [
    {
      "scope": "ITEM",
      "targets": [
        {
          "matchAllDistributors": true,   // Apply to ALL
          "matchAllOutlets": true,
          "matchAllSalesreps": true,
          "matchAllChannels": true,
          "matchAllSegments": true
        }
      ],
      "filters": [
        { "scope": "ORDER_LINE", "field": "sku", "op": "IN", "values": ["SKU001"] }
      ],
      "conditions": [
        { "basis": "LINE_QTY", "slabIndex": 0, "minValue": 1 }
      ],
      "benefits": [
        { "scope": "ORDER_LINE", "type": "FLAT_DISCOUNT", "slabIndex": 0, "flatOff": 50 }
      ]
    }
  ]
}
```

### Advantages
- ✅ Simpler for one-off promotions
- ✅ Everything in one payload
- ✅ No need to create separate target groups
- ✅ Good for quick testing
- ✅ Supports match-all flags for global promotions

---

## Combining Both Approaches

You can use **both** approaches in the same rule! The engine will apply the promotion if:
- **ANY** target group matches **OR**
- **ANY** rule target matches

```json
{
  "rules": [
    {
      "scope": "ITEM",
      "targets": [
        {
          "outletCode": "OUT_SPECIAL",
          "matchAllDistributors": true,
          "matchAllOutlets": false,
          "matchAllSalesreps": true,
          "matchAllChannels": true,
          "matchAllSegments": true
        }
      ],
      "targetGroupIds": [24, 25],  // Also check these groups
      "filters": [...],
      "conditions": [...],
      "benefits": [...]
    }
  ]
}
```

---

## RuleTarget Field Reference

| Field | Type | Description |
|-------|------|-------------|
| `matchAllDistributors` | boolean | If true, applies to all distributors |
| `matchAllOutlets` | boolean | If true, applies to all outlets |
| `matchAllSalesreps` | boolean | If true, applies to all salesreps |
| `matchAllChannels` | boolean | If true, applies to all channels |
| `matchAllSegments` | boolean | If true, applies to all segments |
| `distributorCode` | string | Specific distributor code (if matchAll is false) |
| `outletCode` | string | Specific outlet code (if matchAll is false) |
| `salesrepUsername` | string | Specific salesrep username (if matchAll is false) |
| `channel` | string | Specific channel (GT, MT, etc.) |
| `segment` | string | Specific segment (GOLD, SILVER, etc.) |

---

## Decision Guide

### Use Target Groups When:
- 🎯 You need to reuse the same targeting across multiple promotions
- 🎯 Targeting logic is complex (inclusions + exclusions)
- 🎯 You want to manage customer segments separately
- 🎯 You need to update targeting without changing promotions

### Use Rule Targets When:
- 🎯 Promotion is one-off or temporary
- 🎯 Targeting is simple (e.g., "all GT outlets")
- 🎯 You want everything in one API call
- 🎯 You're testing or prototyping

---

## Testing

See the integration tests for working examples:
- **Target Groups**: `integration_tests/test_promotion_target_group_flow.py`
- **Rule Targets**: `integration_tests/test_promotion_with_targets.py`

Run tests:
```bash
# Test target group approach
pytest integration_tests/test_promotion_target_group_flow.py -v

# Test rule target approach
pytest integration_tests/test_promotion_with_targets.py -v
```
