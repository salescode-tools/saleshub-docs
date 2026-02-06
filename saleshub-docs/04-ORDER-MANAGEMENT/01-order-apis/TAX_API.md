# 🧾 Tax Service API Documentation

The Tax Service manages tax rules and provides calculations for effective tax rates based on SKUs. It supports global fallback rules and SKU-specific overrides.

## 📋 Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/tax-rules` | List all tax rules |
| `POST` | `/tax-rules` | Create or update a tax rule |
| `DELETE` | `/tax-rules/{id}` | Delete a tax rule |
| `GET` | `/tax-rules/effective` | Get resolved tax for a SKU |

---

## 🔍 Endpoints Detail

### 1. List Tax Rules
Returns all tax rules for the current tenant.

**Request:**
`GET /tax-rules`

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "sku": "*",
    "name": "Standard GST",
    "rate": 18.0,
    "components": {
      "cgst": 9.0,
      "sgst": 9.0
    },
    "active": True
  }
]
```

### 2. Create/Update Tax Rule
Upserts a tax rule. If an existing rule for the same `sku` exists, it will be updated. Use `sku: "*"` for a global default.

**Request:**
`POST /tax-rules`

**Body:**
```json
{
  "sku": "SKU123",
  "name": "Luxury Tax",
  "rate": 28.0,
  "components": {
    "cgst": 14.0,
    "sgst": 14.0
  },
  "active": true,
  "extendedAttr": {
     "hsn_code": "123456"
  }
}
```

### 3. Get Effective Tax
Resolves the tax rule for a given SKU. If no specific rule exists for the SKU, it falls back to the global rule (`sku: "*"`).

**Request:**
`GET /tax-rules/effective?sku=SKU123`

**Success Response (200 OK):**
Returns the matched `TaxRule` object.

### 4. Delete Tax Rule
Deletes a specific tax rule by its ID.

**Request:**
`DELETE /tax-rules/{id}`

---

## 📤 MDM Ingestion (Excel/CSV)

Tax rules can be bulk-uploaded via the Master Data Upload API.

**Entity Type:** `TAX_RULE`

**Standard Field Mapping:**
- `skucode` / `sku`: The target SKU (use `*` for global)
- `tax_name` / `name`: Name of the tax
- `tax_rate` / `rate`: Total percentage
- `active`: Status (1, true, yes = active)
- `cgst`, `sgst`, `igst`, `vat`: Component values (optional)

## 🧾 Order Tax Support

Orders and Order Lines now include comprehensive tax data calculated post-promotions.

### Order Level Fields
- `taxAmount`: Total tax amount for the entire order.
- `taxInfo`: JSON breakdown of tax components across all lines.
```json
 {
   "total_tax": 18.5,
   "components": {
     "cgst": {"value": 9.25},
     "sgst": {"value": 9.25}
   }
 }
```

### Order Line Fields
- `taxAmount`: Tax for this specific line item.
- `taxInfo`: Specific rate and component breakdown for the SKU.
```json
 {
   "rate": 18.0,
   "tax_name": "Standard GST",
   "taxable_amount": 100.0,
   "components": {
     "cgst": {"percent": 9.0, "value": 9.0},
     "sgst": {"percent": 9.0, "value": 9.0}
   }
 }
```

**Permissive Parsing Rules:**
- Any non-zero string or values like "yes" or "true" are considered **Active**.
- If `tax_name` is missing, a random name (e.g., `TAX_a1b2c3d4`) is assigned automatically.
- Supports `ignoreTopRows` for files with legacy header structures.
- Extra columns are automatically captured in `extendedAttr` (JSONB).

## 📘 Calculation Example: Classic Invoice Scenario

This example demonstrates how **Item-wise Gross Value**, **Exclusive Tax**, and **Order-Level Promotions** interact to form the final invoice.

### 1. Setup
| Product | Unit Price (MRP) | Quantity | Tax Rule |
| :--- | :--- | :--- | :--- |
| **P1** | ₹100 | 10 | 5% |
| **P2** | ₹50 | 5 | 10% |

### 2. Step-by-Step Calculation

**Step 1: Item-wise Gross Value (Before Tax)**
*   **P1**: 100 × 10 = **₹1,000**
*   **P2**: 50 × 5 = **₹250**
*   **Subtotal (Gross)**: **₹1,250**

**Step 2: Tax Calculation (Item Level - Exclusive)**
*   **P1 Tax**: 5% of 1,000 = **₹50**
*   **P2 Tax**: 10% of 250 = **₹25**
*   **Total Tax**: **₹75**

**Step 3: Promotion Check (Order-Level Discount)**
*   **Rule**: 10% Discount if Order Value > ₹500.
*   **Condition**: ₹1,250 > ₹500 (Eligible).
*   **Discount**: 10% of 1,250 = **₹125**.

**Step 4: Final Invoice Calculation**
*   **Subtotal (Gross)**: ₹1,250
*   **Less Discount**: - ₹125
*   **Add Tax**: + ₹75
*   **Net Payable**: **₹1,200**

### 3. Consolidated Invoice Summary
```text
------------------------------------------------
Invoice Summary
------------------------------------------------
Subtotal (Before Tax):        ₹1,250.00
Order Discount (10%):         ₹125.00
Tax Total:                    ₹75.00 
Net Payable:                  ₹1,200.00
```
