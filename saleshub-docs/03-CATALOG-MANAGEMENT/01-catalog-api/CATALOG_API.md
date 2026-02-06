# Catalog API Documentation

The Catalog API provides a unified, intelligent view of products available to a specific outlet or sales representative. It handles the complex intersection of **Product Master Data**, **Tiered Pricing**, **Territory Entitlements**, and **Active Promotions**.

---

## 🏗️ Core Concept: The Catalog Resolver

Unlike a simple product list, the Catalog API is a **resolver**. It dynamically calculates the state of each item based on the requester's context (Tenant, Outlet, User, and Date).

### Data Scope & Hierarchy
By default, the Catalog API operates in **Hierarchical Mode** (`hierarchical=true`). This means:
1. It identifies all child tenants under the current parent.
2. It executes the catalog resolution function across the entire tenant tree.
3. It aggregates the results into a single merged view.
4. Each item is tagged with a `tenantId` to identify its origin.

---

## 📊 Catalog Item Model

Every item returned by the catalog follows this structure:

| Field | Type | Description |
| :--- | :--- | :--- |
| `tenantId` | String | ID of the tenant where the product record lives. |
| `sku` | String | Unique Stock Keeping Unit. |
| `name` | String | Product display name. |
| `brand` | String | Brand identifier. |
| `category` | String | Product category. |
| `uom` | Enum | Unit of Measure (`UNIT`, `CASE`, `PIECE`). |
| `unitsPerCase` | Short | Pack size conversion factor. |
| `mrp` | Decimal | Maximum Retail Price. |
| `imageUrl` | String | Primary product image URL. |
| `distributorCode` | String | Assigned distributor for this outlet/product. |
| `entitlementActive` | Boolean | True if the outlet is permitted to buy this SKU. |
| `moqUnits` | Integer | Minimum Order Quantity (in units). |
| `priceRuleId` | Long | ID of the winning pricing rule. |
| `priceScopeUsed` | Enum | The scope that provided the current price (e.g., `OUTLET`, `COMPANY`). |
| `priceUnit` | Decimal | Effective price per Unit. |
| `pricePiece` | Decimal | Effective price per Piece. |
| `priceCase` | Decimal | Effective price per Case. |
| `promotions` | List | Active promotional schemes applied to this SKU. |

---

## 🚀 API Endpoints

### 1. Main Catalog List
Retrieve the consolidated catalog for a specific context.

- **Endpoint**: `GET /catalog`
- **Alternative**: `GET /catalog/with-promotions`

#### Query Parameters:
| Parameter | Default | Description |
| :--- | :--- | :--- |
| `outlet_code` | **Conditional** | The code of the outlet viewing the catalog. Required unless `distributor` code is provided. |
| `salesrep` | `(Current User)` | The sales representative username. |
| `distributor` | `null` | Filter results for a specific distributor. |
| `q` | `null` | **Smart Search**: SKU, Name, Brand, Category, or **Product Tags**. |
| `as_of` | `(Today)` | Date for price/promotion validity (`YYYY-MM-DD`). |
| `hierarchical` | `true` | Aggregate results from all child tenants. |
| `limit` | `100` | Pagination limit. |
| `offset` | `0` | Pagination offset. |

---

### 2. SalesRep Specialized View
A simplified view optimized for a SalesRep's current session.

- **Endpoint**: `GET /catalog/salesrep`
- **Query Params**: `outlet_code` (Required), `distributor`, `limit`, `offset`.
- **Logic**: Automatically uses the authenticated user's credentials as the SalesRep context.

### 3. Retailer Smart Resolution
A specialized flow exists for **Retailer Users** (users with `orgType="RETAILER"`).

- **Automatic Context**: If a retailer calls `GET /catalog` **without** providing an `outlet_code`, the system will attempt to deduce the context automatically:
  1. **User-Outlet Mapping**: Checks if the user is explicitly mapped to an outlet in the current tenant.
  2. **Pincode Fallback**: If no mapping, searches for a Distributor matching the user's Pincode.
  3. **Location Fallback**: Finally, searches for the **nearest Distributor** to the user's registered Lat/Lon (Default radius: 5km).
  
- **Configuration**: The location search radius works on a default of 5km but is configurable via the setting `catalog.distributor_search_radius_km`.

- **Result**: The API behaves as if the resolved `outlet_code` or `distributor` (for fallback) was provided manually. This works seamlessly across hierarchical tenants.

---

## 🔍 Smart Search (Tag Matching)

The `q` parameter is more than a string filter. It performs an optimized scan across the hierarchy.

**Search Logic Includes:**
- **Product Tags**: Matches if any tag in the product's tag array contains the query string (Case-insensitive).
- **Metadata**: Matches Brand or Category names.
- **Identifiers**: Partial matches on SKU or Product Name.

### Example Search:
`GET /catalog?q=premium`
*Results will include items from any tenant in the hierarchy where the product has a "PREMIUM" tag, or "Premium" in the name.*

---

## 💡 Use Cases & Examples

### A. Hierarchical Brand View (Parent Tenant)
A parent brand manager wants to see all products across all sub-distributors/tenants.
```bash
curl -X GET "https://api.salescode.ai/catalog?limit=100" \
     -H "Authorization: Bearer <TOKEN>" \
     -H "X-Tenant-Id: parent_brand"
```

### B. Single Tenant Filter (Local View)
A distributor admin wants to see only their local inventory, ignoring the hierarchy.
```bash
curl -X GET "https://api.salescode.ai/catalog?hierarchical=false" \
     -H "X-Tenant-Id: dist_north"
```

### C. Outlet-Specific Tag Search
Finding "Summer Sale" products for a specific store.
```bash
curl -X GET "https://api.salescode.ai/catalog?outlet_code=OUT-55&q=summer" \
     -H "X-Tenant-Id: brand_global"
```

---

## ⚙️ Logic Resolution Order

The Catalog API uses a strictly prioritized resolution engine:

1. **Entitlement Check**: Filters out products the outlet is blocked from purchasing.
2. **Pricing Scopes**: Evaluates prices in the following order (Winner takes all):
   1. `OUTLET_DISTRIBUTOR`
   2. `OUTLET_SALESREP`
   3. `OUTLET`
   4. `SALESREP`
   5. `DISTRIBUTOR`
   6. `COMPANY` (Global Fallback)
3. **Promotion Enrichment**: Injects applicable active schemes into the `promotions` array.

---

## 🔗 Related Documentation
- [Catalog Metadata API](./CATALOG_META_API.md) - Brands, Categories, and Subcategories.
- [Product API](./PRODUCT_API.md) - Master data creation and management.
- [Pricing Engine Guide](./Pricing.md) - Deep dive into price rule calculation.
- [Promotion Engine Guide](./PROMOTION_ENGINE_GUIDE.md) - How schemes are calculated.
