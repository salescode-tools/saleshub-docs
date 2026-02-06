# Promotion API Documentation

This document details the APIs for managing Promotions, including defining schemes, rule-based targeting, and real-time evaluation.

## 1. Data Model (`Promotion` & `PromotionRule`)

A Promotion consists of high-level metadata and a list of rules that define eligibility, conditions, and benefits.

### 1.1 Promotion Metadata

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | Long | Unique database ID (auto-generated) |
| `code` | String | Unique promotion code (Required) |
| `name` | String | Display name of the promotion |
| `kind` | String | Type of promotion: `SLAB_SCHEME`, `BASKET`, `MANUAL` |
| `status` | String | `ACTIVE`, `INACTIVE`, `DRAFT` |
| `priority` | Integer | Evaluation priority (Higher value = Higher priority) |
| `stackable` | Boolean | Whether this promotion can be combined with others |
| `startDate` | Date | Start date (YYYY-MM-DD) |
| `endDate` | Date | End date (YYYY-MM-DD) |
| `tags` | List<String> | List of tags for grouping/filtering |

### 1.2 Promotion Rule

A rule defines *who* gets the promotion, *what* they must buy, and *what* they get.

| Field | Type | Description |
| :--- | :--- | :--- |
| `scope` | String | `ITEM` (Line-item level) or `ORDER` (Total order level) |
| `targets` | List<Target> | Defines eligibility (Outlets, Channels, etc.) |
| `filters` | List<Filter> | Defines product selection (SKUs, Categories) |
| `conditions` | List<Condition> | Defines qualifying criteria (Qty, Value) |
| `benefits` | List<Benefit> | Defines the reward (Free Goods, Discount) |

### 1.3 Target (RuleTarget)

Defines eligibility based on customer/channel attributes.

| Field | Type | Description |
| :--- | :--- | :--- |
| `outletCode` | String | Specific outlet code |
| `channel` | String | Channel (e.g., GT, MT) |
| `distributor` | String | Distributor code |
| `matchAll...` | Boolean | Flags to match ANY outlet, ANY channel, etc. (`matchAllOutlets`, `matchAllChannels`, `matchAllDistributors`) |

#### Example: Complex Multi-Condition Basket Promotion
This promotion applies a 10% overall discount if:
1. The combined quantity of SKU001, SKU002, and SKU003 is at least **4**.
2. Specifically, SKU001 must have a quantity of at least **2**.

```json
{
  "promotion": {
    "code": "COMBO_MIN4_SKU1_MIN2",
    "name": "Combo Scheme: Total 4 Units (Min 2 of SKU001)",
    "kind": "SLAB_SCHEME",
    "status": "ACTIVE",
    "priority": 100,
    "stackable": true
  },
  "rules": [
    {
      "scope": "ORDER",
      "filters": [
        {
          "scope": "ORDER_LINE",
          "field": "sku",
          "op": "IN",
          "values": ["SKU001", "SKU002", "SKU003"]
        }
      ],
      "conditions": [
        { 
          "basis": "BASKET_QTY", 
          "slabIndex": 0, 
          "minValue": 4
        },
        { 
          "basis": "SKU_QTY:SKU001", 
          "slabIndex": 0, 
          "minValue": 2
        }
      ],
      "benefits": [
        { 
          "scope": "ORDER", 
          "type": "PERCENT_DISCOUNT", 
          "slabIndex": 0, 
          "percentOff": 10 
        }
      ]
    }
  ]
}
```

### 1.4 Condition Basis (`RuleCondition.basis`)

The `basis` field determines how the `minValue` and `maxValue` are evaluated.

| Basis | Scope | Description |
| :--- | :--- | :--- |
| `BILL_VALUE` | `ORDER` | Total order sub-total value (after item discounts). |
| `ORDER_QTY` | `ORDER` | Total quantity of all items in the order. |
| `BASKET_QTY` | `ORDER` | Sum of quantities for items matching the rule's `filters`. |
| `BASKET_VALUE` | `ORDER` | Sum of gross values for items matching the rule's `filters`. |
| `SKU_QTY:<SKU>` | `ORDER` | Specific quantity of a single SKU (e.g., `SKU_QTY:SKU001`). |
| `LINE_QTY` | `ITEM` | Quantity of the specific line item being evaluated. |
| `LINE_VALUE` | `ITEM` | Gross value of the specific line item. |

*Note: Multiple conditions with the same `slabIndex` are evaluated as an **AND** operation.*

---

## 2. API Endpoints


### 2.1 Create Promotion

Creates a new promotion with rules.

- **Endpoint**: `POST /promotions`
- **Content-Type**: `application/json`
- **Body**: `PromotionDTO`

#### Example: Buy 2 SKUX Get 1 Free (Slab Scheme)
```json
{
  "promotion": {
    "code": "B2G1_SKU004",
    "name": "Buy 2 SKU004 Get 1 Free",
    "kind": "SLAB_SCHEME",
    "status": "ACTIVE",
    "priority": 100,
    "stackable": true,
    "startDate": "2024-01-01",
    "endDate": "2030-12-31"
  },
  "rules": [
    {
      "scope": "ITEM",
      "filters": [
        {
          "scope": "ORDER_LINE",
          "field": "sku",
          "op": "IN",
          "values": ["SKU004"]
        }
      ],
      "conditions": [
        { "basis": "LINE_QTY", "slabIndex": 0, "minValue": 2, "maxValue": 9999 }
      ],
      "benefits": [
        { "scope": "ORDER_LINE", "type": "FREE_GOODS", "slabIndex": 0, "freeSku": "SKU004", "freeQty": 1 }
      ]
    }
  ]
}
```

#### Example: Targeted Promotion (Specific Channel)
This promotion only applies to outlets in the "GT" channel.

```json
{
  "promotion": {
    "code": "GT_EXCLUSIVE_OFFER",
    "name": "10% Off for General Trade",
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
          "channel": "GT",
          "matchAllOutlets": true,
          "matchAllDistributors": true
        }
      ],
      "filters": [
        { "scope": "ORDER_LINE", "field": "sku", "op": "IN", "values": ["SKU_ABC"] }
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

### 2.2 List Promotions

Retrieves all promotions. Can be filtered by tags.

- **Endpoint**: `GET /promotions`
- **Query Params**:
  - `tags`: (Optional) List of tags to filter by. Supports multiple values (e.g., `?tags=summer&tags=sale`).
- **Response**: `List<Promotion>`

#### Example: Filter by Tags
`GET /promotions?tags=vip&tags=exclusive`
(Returns promotions that have *any* of the specified tags)

### 2.3 Get Unique Promotion Tags

Retrieves a sorted list of all unique tags currently associated with any promotion in the tenant.

- **Endpoint**: `GET /promotions/tags`
- **Response**: `List<String>`
- **Example**: `["holiday", "discount", "seasonal"]`

### 2.4 Get Promotion Details

Retrieves a single promotion by ID, including its rules.

- **Endpoint**: `GET /promotions/{id}`
- **Path Params**: `id` (Long)
- **Response**: `PromotionDTO`

### 2.5 Update Promotion

Updates an existing promotion structure.

- **Endpoint**: `PUT /promotions/{id}`
- **Path Params**: `id` (Long)
- **Body**: `PromotionDTO`

### 2.6 Delete Promotion

Deletes a promotion.

- **Endpoint**: `DELETE /promotions/{id}`
- **Path Params**: `id` (Long)
- **Response**: `204 No Content`

### 2.7 Patch Promotion Tags

Efficiently add or remove tags from a promotion without updating the full structure.

- **Endpoint**: `PATCH /promotions/{id}/tags`
- **Path Params**: `id` (Long)
- **Body**: `PatchPromotionTagsRequest`

#### JSON Payload Example
```json
{
  "addTags": ["special-offer", "holiday"],
  "removeTags": ["draft"]
}
```
*Logic*:
- Tags in `addTags` are appended to the promotion's existing tags (duplicates ignored).
- Tags in `removeTags` are removed from the promotion's existing tags.


### 2.8 Evaluate Promotions

Simulates or performs real-time promotion application against a basket of items.

- **Endpoint**: `POST /promotions/evaluate`
- **Body**: `OrderRequest` (or `EvaluationRequest`)

#### Example Payload
```json
{
  "outletCode": "OUT_ABC_001",
  "channel": "GT",
  "lines": [
    { "sku": "SKU004", "quantity": 10, "unitPrice": 100 }
  ]
}
```

#### Example Response
```json
{
  "appliedPromotions": [
    {
      "promotionId": 1234,
      "code": "B2G1_SKU004",
      "discountAmount": 0,
      "freeItems": [
        { "sku": "SKU004", "quantity": 5 }
      ]
    }
  ],
  "netAmount": 1000.0,
  "lines": [
    {
      "sku": "SKU004",
      "quantity": 10,
      "lineTotal": 1000.0,
      "appliedDetails": [...]
    }
  ]
}
```
