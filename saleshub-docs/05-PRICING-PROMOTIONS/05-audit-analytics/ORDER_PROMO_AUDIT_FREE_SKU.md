# Order Promo Audit: Free SKU Tracking

## Overview
Enhanced the `order_promo_audit` table to track free goods promotions by adding `free_sku` and `free_qty` columns.

## Database Changes

### Migration: V27_add_free_sku_to_promo_audit.sql
```sql
ALTER TABLE order_promo_audit 
ADD COLUMN IF NOT EXISTS free_sku TEXT,
ADD COLUMN IF NOT EXISTS free_qty INTEGER;

CREATE INDEX IF NOT EXISTS opa_free_sku_idx 
ON order_promo_audit(tenant_id, free_sku) 
WHERE free_sku IS NOT NULL;
```

## Model Changes

### OrderPromoAudit.java
Added two new fields:
- `public String freeSku` - The SKU code of the free product
- `public Integer freeQty` - The quantity of free products given

## DAO Changes

### OrderDaoPlainJdbc.java

#### INSERT Statements Updated
Both ORDER_LINE and ORDER-level audit inserts now include:
```java
// Free goods tracking
if (ap.freeSku != null && ap.freeQty != null && ap.freeQty > 0) {
  aps.setString(10, ap.freeSku);
  aps.setInt(11, ap.freeQty);
} else {
  aps.setNull(10, Types.VARCHAR);
  aps.setNull(11, Types.INTEGER);
}
```

#### SELECT Queries Updated
All queries now include `free_sku` and `free_qty` in the SELECT list:
- `listAudit(Long orderId, Long promoId, ...)`
- `listAudit(Long orderId, Long promoId, String outletCode, ...)`
- `get(String id, boolean withLines, Connection conn)`

#### Mapping Method Updated
`mapOrderAudit(ResultSet rs)` now extracts:
```java
a.freeSku = rs.getString("free_sku");
Integer freeQtyObj = (Integer) rs.getObject("free_qty");
a.freeQty = freeQtyObj;
```

## Usage Example

When a promotion with free goods is applied:

```json
{
  "appliedPromotions": [
    {
      "promotionId": 123,
      "ruleId": 456,
      "scope": "ITEM",
      "lineIndex": 0,
      "discountAmount": 0,
      "freeGoodsValue": 100,
      "freeQty": 2,
      "freeSku": "SKU_FREE_001"
    }
  ]
}
```

The audit record will capture:
- `promo_id`: 123
- `discount_value`: 100 (value of free goods)
- `free_sku`: "SKU_FREE_001"
- `free_qty`: 2

## Benefits

1. **Complete Audit Trail**: Track exactly which free products were given in each promotion
2. **Inventory Management**: Know which SKUs were given away as free goods
3. **Analytics**: Analyze which free goods promotions are most popular
4. **Reconciliation**: Match free goods given with inventory movements

## Migration Steps

1. Apply the V27 migration to add the columns
2. Restart the application to pick up the code changes
3. Existing audit records will have NULL values for free_sku and free_qty
4. New orders with free goods promotions will populate these fields

## Query Examples

### Find all free goods promotions
```sql
SELECT * FROM order_promo_audit 
WHERE free_sku IS NOT NULL 
ORDER BY created_at DESC;
```

### Count free goods by SKU
```sql
SELECT free_sku, SUM(free_qty) as total_qty, COUNT(*) as promo_count
FROM order_promo_audit
WHERE free_sku IS NOT NULL
GROUP BY free_sku
ORDER BY total_qty DESC;
```

### Find orders with specific free SKU
```sql
SELECT DISTINCT order_id, outlet_code, created_at
FROM order_promo_audit
WHERE free_sku = 'SKU_FREE_001'
ORDER BY created_at DESC;
```
