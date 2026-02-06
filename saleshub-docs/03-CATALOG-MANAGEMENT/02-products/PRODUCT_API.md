# Product API Documentation

This document details the APIs for managing Products in the SalesCode Lite application, including the definition of product metadata, pricing, attributes, and tags.

## 1. Data Model (`Product`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | Long | Unique database ID (auto-generated) |
| `sku` | String | Unique Stock Keeping Unit identifier (Required, Unique per Tenant) |
| `name` | String | Display name of the product |
| `uom` | String | Unit of Measure (e.g., UNIT, CASE, BOX) |
| `brand` | String | Brand name |
| `category` | String | Product category |
| `subcategory` | String | Product sub-category |
| `mrp` | Double | Maximum Retail Price |
| `unitsPerCase` | Integer | Number of units per case (default 1) |
| `active` | Boolean | Whether the product is active/sellable |
| `tags` | List<String> | List of tags for grouping, filtering, or special handling (e.g., "new", "summer-sale") |
| `imageUrl` | String | Primary image URL |
| `images` | List<String> | List of additional image URLs |
| `description` | String | Detailed product description |
| `extendedAttr` | JSON | Flexible JSON object for custom attributes |
| `createdAt` | Timestamp | Creation timestamp |

---

## 2. API Endpoints

### 2.1 List Products

Retrieves products for the tenant. Can be filtered by brand, category, subcategory, or tags. Filters are applied as **AND** logic.

- **Endpoint**: `GET /products`
- **Query Params**:
    - `brand`: (Optional) Brand code.
    - `category`: (Optional) Category code.
    - `subcategory`: (Optional) Subcategory code.
    - `tags`: (Optional) List of tags to filter by. Supports multiple values (e.g., `?tags=new&tags=promo`).
    - `hierarchical`: (Optional, Default: **true**) If true, fetches products from current tenant AND all child tenants.
- **Response**: `List<Product>` (Includes a `tenantId` field to identify source)

#### Example: Hierarchical Search (Default)
`GET /products?category=FMCG` (Searches whole hierarchy)

#### Example: Local Search Only
`GET /products?category=FMCG&hierarchical=false` (Searches only current tenant)

---


### 2.2 Search Products

Performs a bulk search for products across multiple fields. Filters are applied as **OR** logic (one or more matches).

- **Endpoint**: `GET /products/search`
- **Query Params**:
    - `skus`: (Optional) List of SKUs to match.
    - `brands`: (Optional) List of Brand codes to match.
    - `categories`: (Optional) List of Category codes to match.
    - `subcategories`: (Optional) List of Subcategory codes to match.
- **Response**: `List<Product>`

#### Example: Bulk Search
`GET /products/search?brands=Sony&brands=Apple&categories=Laptops`

### 2.3 Get Unique Tags (Discovery)

Retrieves all unique tags used across all products in the current tenant. Useful for building filter UIs or autocomplete inputs.

- **Endpoint**: `GET /products/tags`
- **Response**: `List<String>` (Sorted alphabetically)

#### Example Response
```json
["Electronics", "Gadget", "Home", "New-Arrival", "Sale"]
```

---

### 2.4 Get Product by ID

Retrieves a single product by its database ID.

- **Endpoint**: `GET /products/{id}`
- **Path Params**: `id` (Long)
- **Response**: `Product`

### 2.3 Get Product by SKU

Retrieves a single product by its SKU.

- **Endpoint**: `GET /products/sku/{sku}`
- **Path Params**: `sku` (String)
- **Response**: `Product`

### 2.4 Create Product

Creates a new product. `sku` and `name` are required.

- **Endpoint**: `POST /products`
- **Content-Type**: `application/json`
- **Body**: `CreateProductRequest`

#### JSON Payload Example
```json
{
  "sku": "PROD-001",
  "name": "Super Widget",
  "uom": "UNIT",
  "brand": "WidgetCo",
  "category": "Electronics",
  "mrp": 199.99,
  "unitsPerCase": 1,
  "active": true,
  "tags": ["new-arrival", "bestseller"],
  "imageUrl": "http://example.com/widget.jpg",
  "description": "The best widget in town",
  "extendedAttr": {
    "color": "red",
    "weight": "1kg"
  }
}
```

### 2.5 Update Product (by ID)

Updates an existing product by its ID. Supports partial updates (only fields provided in the JSON will be updated).

- **Endpoint**: `PUT /products/{id}`
- **Path Params**: `id` (Long)
- **Body**: `UpdateProductRequest`

#### JSON Payload Example (Partial Update)
```json
{
  "name": "Super Widget V2",
  "tags": ["bestseller", "clearance"],
  "mrp": 179.99
}
```

### 2.6 Update Product (by SKU)

Updates an existing product via its SKU. Useful for integrations where ID is unknown.

- **Endpoint**: `PUT /products/sku/{sku}`
- **Path Params**: `sku` (String)
- **Body**: `UpdateProductRequest`

### 2.7 Patch Product Tags

Efficiently add or remove tags from a product without sending the full tag list or other product details.

- **Endpoint**: `PATCH /products/{id}/tags`
- **Path Params**: `id` (Long)
- **Body**: `PatchProductTagsRequest`

#### JSON Payload Example
```json
{
  "addTags": ["special-offer", "holiday"],
  "removeTags": ["new-arrival"]
}
```
*Logic*:
- Tags in `addTags` are appended to the product's existing tags (duplicates ignored).
- Tags in `removeTags` are removed from the product's existing tags.
- Both lists are optional.

### 2.8 Patch Product Tags (by SKU)

Same as above, but identifies the product by SKU.

- **Endpoint**: `PATCH /products/sku/{sku}/tags`
- **Path Params**: `sku` (String)
- **Body**: `PatchProductTagsRequest`

### 2.9 Toggle Active Status

Quickly enable or disable a product.

- **Endpoint**: `PATCH /products/{id}/active`
- **Body**: `{"active": boolean}`

```json
{ "active": false }
```

### 2.10 Delete Product

Deletes a product by ID.

- **Endpoint**: `DELETE /products/{id}`
- **Path Params**: `id` (Long)
- **Response**: `204 No Content`

---

## 3. Custom Units of Measure (UoM) Management

Products can have custom units of measure beyond the standard UNIT, CASE, and PIECE. This allows for flexible ordering in units like BOX, TRAY, PALLET, CARTON, DOZEN, etc.

### 3.1 Data Model (`ProductUomConversion`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | Long | Unique database ID |
| `tenantId` | String | Tenant identifier |
| `sku` | String | Product SKU this conversion applies to |
| `uom` | String | Custom unit of measure (e.g., "BOX", "TRAY", "PALLET") |
| `conversionFactor` | Double | How many base units (PIECEs) in this UoM |
| `baseUom` | String | Base unit for conversion (default: "PIECE") |
| `active` | Boolean | Whether this conversion is active |
| `createdAt` | Timestamp | Creation timestamp |
| `updatedAt` | Timestamp | Last update timestamp |

### 3.2 List UoM Conversions for a Product

Retrieves all custom UoM conversions defined for a specific product.

- **Endpoint**: `GET /products/{sku}/uom-conversions`
- **Path Params**: `sku` (String) - Product SKU
- **Response**: `List<ProductUomConversion>`

#### Example Response
```json
[
  {
    "id": 1,
    "tenantId": "tenant_001",
    "sku": "RICE_25KG",
    "uom": "BOX",
    "conversionFactor": 12.0,
    "baseUom": "PIECE",
    "active": true,
    "createdAt": "2026-01-31T10:00:00Z",
    "updatedAt": "2026-01-31T10:00:00Z"
  },
  {
    "id": 2,
    "tenantId": "tenant_001",
    "sku": "RICE_25KG",
    "uom": "PALLET",
    "conversionFactor": 40.0,
    "baseUom": "PIECE",
    "active": true,
    "createdAt": "2026-01-31T10:05:00Z",
    "updatedAt": "2026-01-31T10:05:00Z"
  }
]
```

### 3.3 Create Custom UoM Conversion

Defines a new custom unit of measure for a product.

- **Endpoint**: `POST /products/{sku}/uom-conversions`
- **Path Params**: `sku` (String) - Product SKU
- **Content-Type**: `application/json`
- **Body**: `CreateUomConversionRequest`

#### Request Fields
| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `uom` | String | Yes | Custom UoM name (e.g., "BOX", "TRAY") |
| `conversionFactor` | Double | Yes | Conversion factor (must be > 0) |
| `baseUom` | String | No | Base unit (default: "PIECE") |

#### Example Request
```json
{
  "uom": "BOX",
  "conversionFactor": 12.0,
  "baseUom": "PIECE"
}
```

**Response**: `201 Created` with the created `ProductUomConversion` object

**Interpretation**: 1 BOX = 12 PIECEs

#### Use Case Example
```json
// Define "PALLET" for bulk orders
{
  "uom": "PALLET",
  "conversionFactor": 40.0,
  "baseUom": "PIECE"
}
```

### 3.4 Update UoM Conversion

Updates an existing UoM conversion's factor or active status.

- **Endpoint**: `PUT /products/{sku}/uom-conversions/{id}`
- **Path Params**: 
  - `sku` (String) - Product SKU
  - `id` (Long) - Conversion ID
- **Body**: `UpdateUomConversionRequest`

#### Request Fields (All Optional)
| Field | Type | Description |
| :--- | :--- | :--- |
| `conversionFactor` | Double | New conversion factor |
| `active` | Boolean | Enable/disable this conversion |

#### Example Request
```json
{
  "conversionFactor": 48.0,
  "active": true
}
```

**Response**: `200 OK` with the updated `ProductUomConversion` object

### 3.5 Delete (Deactivate) UoM Conversion

Soft-deletes a UoM conversion by setting it to inactive.

- **Endpoint**: `DELETE /products/{sku}/uom-conversions/{id}`
- **Path Params**: 
  - `sku` (String) - Product SKU
  - `id` (Long) - Conversion ID
- **Response**: `204 No Content`

**Note**: This is a soft delete - the conversion is marked as `active: false` but remains in the database.

### 3.6 Using Custom UoMs in Orders

Once a custom UoM is defined, it can be used when creating orders:

```json
POST /orders
{
  "outletCode": "OUTLET_001",
  "distributor": "DIST_001",
  "lines": [
    {
      "sku": "RICE_25KG",
      "uom": "BOX",
      "qty": 5.0,  // 5 boxes
      "unitPrice": 500.0
    }
  ]
}
```

**System Behavior**:
- Looks up the conversion factor for "BOX" (e.g., 12.0)
- Calculates `lineUnits = qty × conversionFactor = 5 × 12 = 60 PIECEs`
- Stores `qty: 5.0` in `extendedAttr` for reference
- Backward compatible: Legacy orders using `qtyCases` and `qtyPieces` continue to work

### 3.7 Custom UoM Pricing

Price rules can include custom UoM prices in the `uomPrices` field:

```json
POST /price-rules
{
  "productId": "RICE_25KG",
  "scope": "OUTLET",
  "outletCode": "OUTLET_001",
  "uomPrices": {
    "BOX": 5500.0,
    "PALLET": 18000.0
  },
  "startOn": "2026-01-01",
  "endOn": "2026-12-31"
}
```

**Priority**: Custom UoM prices take precedence over legacy `priceUnit`, `priceCase`, `pricePiece` fields.

---

## 4. Best Practices

### Backward Compatibility
- All existing code using `qtyCases` and `qtyPieces` continues to work
- The system automatically falls back to `unitsPerCase` for "CASE" UoM if no custom conversion is defined
- Legacy price rules remain functional

### Conversion Factor Guidelines
- **Always relative to base unit (PIECE)**: If 1 BOX = 12 pieces, factor = 12.0
- **Support decimals**: 0.5 factor means 1 UoM = 0.5 pieces (half-unit)
- **No zero or negative factors**: System validation enforces positive values

### Naming Conventions
- Use uppercase for UoM names: "BOX", "TRAY", "PALLET"
- Be consistent across products: If you use "CARTON", don't also use "CTN"
- Industry-standard UoMs: DOZEN, GROSS (144), CASE, BUNDLE, etc.
