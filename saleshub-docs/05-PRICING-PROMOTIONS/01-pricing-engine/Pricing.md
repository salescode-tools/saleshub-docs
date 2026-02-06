# B2B Pricing Engine — Design & Options

*Last updated: 30 Oct 2025 (IST)*

## 1) Purpose & Scope

A clear, deterministic way to compute selling price for a product in a B2B workflow, given: **tenant**, **product (SKU)**, **buyer outlet**, **optional distributor**, **optional sales rep**, **date**, and **order quantities**. This document aligns with the provided tables:

* `product(id, tenant_id, sku, uom, units_per_case, mrp, …)`
* `sell_entitlement(id, tenant_id, product_id, distributor_id, salesrep_id, moq_units, lead_time_days, active, …)`
* `price_rule(id, tenant_id, product_id TEXT, outlet_code, salesrep, distributor, scope, price_unit, price_case, price_piece, min_*, start_on, end_on, …)`

> Note: `price_rule.product_id` is a `TEXT`. In practice this maps to `product.sku` (recommended) or another agreed product key. If you prefer FK to `product.id`, change the column type + FK accordingly.

---

## 2) Core Concepts

### 2.1 Price scopes (priority)

The engine supports multiple targeting scopes. Priority from most-specific → least-specific:

1. **OUTLET_DISTRIBUTOR** (exact outlet + distributor)
2. **OUTLET** (exact outlet)
3. **SALESREP** (exact sales rep)
4. **COMPANY** (tenant-wide default)

> Rationale: the more specific the targeting, the higher the precedence. When multiple rules exist within the same scope, we break ties using time-window recency and then explicit tiebreakers (see §4.4).

### 2.2 Time windows

A rule is **active** if `start_on <= as_of_date` and (`end_on IS NULL OR end_on >= as_of_date`).

### 2.3 UoM & conversions

Prices may be provided in any of: `price_unit`, `price_case`, `price_piece`.

* If a requested UoM’s price is missing, we can **derive** using `product.units_per_case` where sensible (e.g., case ↔ unit). “Piece” is treated as a display/package split of unit; if not applicable for a product, leave null and do not derive.
* Always keep internal math in **unit** price for comparability, then scale to requested UoM for output.

### 2.4 Minimum order quantities

A rule may require `min_units`, `min_cases`, or `min_pieces`. The request must satisfy **at least one** applicable minimum for the chosen UoM, or the rule is **ineligible**.

### 2.5 Entitlements (supply-side constraints)

`sell_entitlement` expresses if a product can be sold by a `distributor`/`salesrep` and any constraints like `moq_units` and `lead_time_days`.

* Entitlement is **checked before** pricing.
* When applicable, the engine enforces the **higher** MOQ between `entitlement.moq_units` and `price_rule.min_*` (after UoM normalization).

---

## 3) Inputs & Outputs

### 3.1 Inputs

```
tenant_id: text
sku: text                -- price_rule.product_id
outlet_code: text        -- optional for COMPANY/SALESREP scope
distributor: text|null   -- required for OUTLET_DISTRIBUTOR resolution
salesrep: text|null
as_of_date: date
request: {
  uom: 'UNIT'|'CASE'|'PIECE',
  qty: numeric(10,5)     -- quantity in requested UoM
}
```

### 3.2 Output (example)

```
{
  sku: "ABC-100",
  resolved_scope: "OUTLET",
  rule_id: 12345,
  price: {
    per_uom: "CASE",
    per_uom_value: 4320.00,
    per_unit_value: 360.00,    -- normalized to unit for auditing
    currency: "INR"
  },
  qty: {
    uom: "CASE",
    requested: 10,
    normalized_units: 10 * product.units_per_case
  },
  moq_enforced: {
    source: "ENTITLEMENT",     -- ENTITLEMENT | PRICE_RULE | NONE
    units_required: 120
  },
  validity: { start_on: "2025-10-01", end_on: null },
  notes: ["Derived from CASE", "Tie-breaker: latest start_on"]
}
```

---

## 4) Resolution Algorithm

### 4.1 High-level steps

1. **Load product** by `tenant_id` + `sku` → get `units_per_case`, `uom` etc.
2. **Check entitlement** (

    * If order is via distributor or salesrep, query `sell_entitlement` by `(tenant_id, product_id, distributor_id?, salesrep_id?)` with `active=true`.
    * If no matching active entitlement, **fail** with a clear reason.
    * Compute `entitlement_moq_units` and note `lead_time_days` if present.
      )
3. **Fetch candidate price rules** filtered by `tenant_id`, `product_id`, `as_of_date` time window, and scope targets that match the request context.
4. **Filter by MOQ**: reject any rule whose minimums aren’t met by the requested quantity (after converting to **units** for comparison). The effective MOQ is `max(entitlement_moq_units, rule_min_units)`.
5. **Rank candidates** using:

    * Scope priority (§2.1)
    * `start_on` DESC (most recent first)
    * `end_on` ASC NULLS LAST (earliest closing first; open-ended beats far-future when start_on equal)
    * `id` DESC (stable deterministic tiebreak)
6. **Select best rule** and compute the **effective price**:

    * Normalize all provided prices to **per-unit**.
    * If the requested UoM’s price is null, derive from per-unit if safe.
    * Multiply by requested quantity for extended value if needed.
7. Return the structured **pricing result** (see §3.2), including provenance and tie-break notes.

### 4.2 UoM normalization

```
per_unit = COALESCE(
  price_unit,
  price_case / units_per_case,   -- when available
  price_piece                    -- when piece==unit for this SKU; otherwise disallow
)
```

To output a CASE price when missing:

```
price_case = per_unit * units_per_case
```

### 4.3 MOQ normalization

Convert the request to **units**:

```
req_units =
  CASE request.uom
    WHEN 'UNIT'  THEN request.qty
    WHEN 'CASE'  THEN request.qty * units_per_case
    WHEN 'PIECE' THEN derive_to_units(request.qty) -- if defined for SKU
  END
```

Compute `rule_min_units` from `min_units|min_cases|min_pieces` similarly, then enforce:

```
req_units >= GREATEST(COALESCE(entitlement_moq_units, 0), COALESCE(rule_min_units, 0))
```

### 4.4 Tie-breakers

Within the same scope and time window, the winning rule is:

1. largest `start_on`, 2) smallest `end_on` (NULLs last), 3) highest `id`.

### 4.5 Fallbacks & errors

* If no rule is eligible but `product.mrp` exists, optionally **fall back** to MRP (configurable). Mark `resolved_scope = 'MRP'`.
* If nothing resolves, return a typed error: `NO_PRICE_RULE` with reason.

---

## 5) SQL Patterns

### 5.1 Candidate selection (single SKU)

```sql
-- Inputs : :tenant_id, :sku, :as_of, :outlet_code, :salesrep, :distributor
WITH p AS (
  SELECT id, units_per_case
  FROM product
  WHERE tenant_id = :tenant_id AND sku = :sku
)
SELECT r.*,
       p.units_per_case
FROM price_rule r
JOIN p ON TRUE
WHERE r.tenant_id = :tenant_id
  AND r.product_id = :sku
  AND r.start_on <= :as_of
  AND (r.end_on IS NULL OR r.end_on >= :as_of)
  AND (
    (r.scope = 'OUTLET_DISTRIBUTOR' AND r.outlet_code = :outlet_code AND r.distributor = :distributor)
 OR (r.scope = 'OUTLET'            AND r.outlet_code = :outlet_code AND r.distributor IS NULL AND r.salesrep IS NULL)
 OR (r.scope = 'SALESREP'          AND r.salesrep = :salesrep       AND r.outlet_code IS NULL AND r.distributor IS NULL)
 OR (r.scope = 'COMPANY'           AND r.outlet_code IS NULL        AND r.salesrep IS NULL AND r.distributor IS NULL)
  )
ORDER BY CASE r.scope
           WHEN 'OUTLET_DISTRIBUTOR' THEN 1
           WHEN 'OUTLET'            THEN 2
           WHEN 'SALESREP'          THEN 3
           WHEN 'COMPANY'           THEN 4
         END,
         r.start_on DESC,
         r.end_on ASC NULLS LAST,
         r.id DESC
;
```

### 5.2 Helpful indexes

```sql
CREATE INDEX IF NOT EXISTS price_rule_active_idx
  ON price_rule(tenant_id, product_id, start_on, end_on);

CREATE INDEX IF NOT EXISTS price_rule_scope_outlet_idx
  ON price_rule(tenant_id, scope, outlet_code);

CREATE INDEX IF NOT EXISTS price_rule_scope_salesrep_idx
  ON price_rule(tenant_id, scope, salesrep);

CREATE INDEX IF NOT EXISTS price_rule_scope_distributor_idx
  ON price_rule(tenant_id, scope, distributor);
```

### 5.3 Entitlement lookup

```sql
SELECT 1
FROM sell_entitlement se
JOIN product p ON p.tenant_id = se.tenant_id AND p.id = se.product_id
WHERE se.tenant_id = :tenant_id
  AND p.sku = :sku
  AND COALESCE(se.active, TRUE)
  AND (se.distributor_id = :distributor_id OR :distributor_id IS NULL)
  AND (se.salesrep_id    = :salesrep_id    OR :salesrep_id    IS NULL)
LIMIT 1;
```

---

## 6) Service Contract (suggested)

### 6.1 REST endpoint

```
POST /pricing/resolve
{
  "tenantId": "t1",
  "sku": "SKU-001",
  "asOf": "2025-10-30",
  "outletCode": "OUT-9",
  "distributor": "DIST-1",
  "salesrep": null,
  "request": { "uom": "CASE", "qty": 10 }
}
```

**200 OK**

```
{
  "resolvedScope": "OUTLET_DISTRIBUTOR",
  "ruleId": 9123,
  "price": { "perUom": "CASE", "perUomValue": 4320.0, "perUnitValue": 360.0 },
  "moq": { "unitsRequired": 120, "source": "PRICE_RULE" },
  "leadTimeDays": 3,
  "validity": { "startOn": "2025-10-01", "endOn": null },
  "explain": ["scope rank 1", "latest start_on"]
}
```

**4xx** (examples)

* `NO_ENTITLEMENT`
* `NO_PRICE_RULE`
* `MOQ_NOT_MET`, includes `requiredUnits` and `requestedUnits`.

---

## 7) Admin & Authoring Guidelines

1. **Avoid overlapping rules** in the same scope/time window for the same SKU unless intentional (promotions, testing). Overlaps increase tie-break reliance.
2. **Use COMPANY scope** for safe defaults per SKU.
3. **Always fill `start_on`**; use open-ended `end_on` for evergreen rules.
4. **Record rationale** in `extended_attr` (e.g., `{ "promo": "Diwali", "channel": "GT" }`).
5. **Keep UoM consistent** per category; only use `price_piece` where it truly differs from `unit`.

---

## 8) Edge Cases & Options

* **Derivation guardrails**: If `units_per_case` is not set or is 0, disallow case↔unit derivation.
* **Promotions stacking** (optional): Allow an additional discount field in `extended_attr` (e.g., `extra_discount_pct`), applied after base price resolution. Log stacking in `explain`.
* **MRP ceiling** (optional): Reject any computed per-unit > `product.mrp` when `mrp` is present.
* **Geo/customer class** (optional): Extend scope with customer class/city. Keep the same priority logic (more fields ⇒ higher priority).
* **Product groups** (optional): Support group pricing by using a convention in `price_rule.product_id` (e.g., prefixes or a separate `product_group_id`). Be explicit in docs if wildcards are adopted.

---

## 9) Example Walkthrough

> **Scenario**: Tenant T1, SKU=SK-10 (`units_per_case=12`). Order on 2025‑11‑01 for **10 CASES** to Outlet O1 via Distributor D1.

1. Entitlement exists for (SK-10, D1) with `moq_units=120`.
2. Price rules:

    * R1: OUTLET_DISTRIBUTOR(O1,D1): `price_case=4000`, `start_on=2025-10-01`.
    * R2: OUTLET(O1): `price_case=4200`, `start_on=2025-09-01`.
    * R3: COMPANY: `price_unit=380`.
3. Candidates are all valid by date; MOQ: 10 CASE = 120 units meets entitlement MOQ.
4. Pick R1 (highest scope). Per-unit = 4000/12 ≈ 333.33; Output per CASE = 4000; `resolved_scope=OUTLET_DISTRIBUTOR`.

---

## 10) Performance Notes

* Index by **(tenant_id, product_id, start_on, end_on)** and by **scope + target keys** to prune scans (§5.2).
* For bulk cart pricing (many SKUs), batch fetch `product` and `price_rule` rows, then resolve in-memory; push only final picks to DB.
* Cache active rules per `(tenant, sku)` partition by **month** (start/end spans) to minimize date checks.

---

## 11) Future Enhancements

* **Versioned rule audit** (history table with `valid_from/valid_to`).
* **Rule simulator** in admin UI (what-if across outlets/distributors).
* **Discount engines** (tiered breaks, buy‑X‑get‑Y) separate from base price table.
* **Cost-based guardrails** (min margin %).

---

## 12) Quick Checklist

* [ ] Product has `units_per_case` set
* [ ] Entitlement active and MOQ known
* [ ] At least one rule valid for the date
* [ ] Scope priority & tiebreakers deterministic
* [ ] UoM conversions safe; per-unit audit logged
* [ ] Indexes created and vacuum/analyze scheduled
