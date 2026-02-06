# Catalog Meta API Documentation

This document details the APIs for managing hierarchical catalog metadata (Groups, Brands, Categories, Subcategories, and Mother Codes) in the SalesCode Lite application.

## 1. Data Model (`CatalogMetaDTO`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | Long | Unique database ID (auto-generated) |
| `type` | String | One of: `BRAND`, `CATEGORY`, `SUBCATEGORY`, `MOTHERCODE`, `GROUP` |
| `code` | String | Unique identifier for the metadata item (e.g., `DAIRY`, `AMUL`) |
| `name` | String | Display label for the item |
| `description` | String | (Optional) Detailed description |
| `imageUrl` | String | (Optional) URL for image or logo |
| `parentType` | String | (Optional) Type of the parent item |
| `parentCode` | String | (Optional) Code of the parent item |
| `extendedAttr` | JSON | Flexible JSON object for custom attributes |
| `brands` | List<String>| List of associated Brand codes (valid for Category/Subcategory) |

> **Tip**: The `code` values defined here (for Brand, Category, Subcategory) are used as filter parameters in the [Product API](./PRODUCT_API.md).
> 
> **Hierarchy Rules**:
> - **SUBCATEGORY**: Must have `CATEGORY` as parent.
> - **CATEGORY**: Can have `GROUP` as parent.
> - **BRAND**: Can have `GROUP` as parent.
> - **GROUP**: High-level organizational unit (no parent).

---

## 2. API Endpoints

### 2.1 List Catalog Metadata

Retrieves a list of metadata entries based on filters.

- **Endpoint**: `GET /catalog/meta`
- **Query Parameters**:
    - `type`: (Optional) Filter by type (`BRAND`, `CATEGORY`, etc.)
    - `parentType`: (Optional) Filter by parent type
    - `parentCode`: (Optional) Filter by parent code
    - `q`: (Optional) Search query (matches code, name, or description)
    - `limit`: Max results (default 100)
    - `offset`: Pagination offset (default 0)
    - `hierarchical`: (Optional) List metadata from child tenants (default true)

#### Example
`GET /catalog/meta?type=CATEGORY`

---

### 2.2 Get Metadata Item

Retrieves a single metadata entry by its type and code.

- **Endpoint**: `GET /catalog/meta/{type}/{code}`
- **Path Parameters**:
    - `type`: Metadata type
    - `code`: Metadata code

---

### 2.3 Get Aggregated Brands

Retrieves all unique brands associated with a specific metadata code and its direct children.

- **Endpoint**: `GET /catalog/meta/{type}/{code}/brands`
- **Logic**:
    - For a **CATEGORY**: Returns brands linked to the category itself PLUS all brands linked to its **SUBCATEGORIES**.
    - For a **SUBCATEGORY**: Returns its own linked brands.
- **Response**: `List<CatalogMetaDTO>` (Full brand objects)

#### Example
`GET /catalog/meta/CATEGORY/DAIRY/brands`

---

### 2.4 Create Metadata Entry

Creates a new catalog metadata entry.

- **Endpoint**: `POST /catalog/meta`
- **Constraint**: If `brands` are provided, each brand code must already exist as a `BRAND` type entry.

#### Request Body
```json
{
  "type": "CATEGORY",
  "code": "DAIRY",
  "name": "Dairy Products",
  "description": "Milk, Butter, Cheese, etc.",
  "imageUrl": "https://cdn.example.com/cats/dairy.png",
  "extendedAttr": { "priority": 1 },
  "brands": ["AMUL", "NESTLE"]
}
```

#### Example: Group Parent
```json
{
  "type": "GROUP",
  "code": "BEVERAGES",
  "name": "All Beverages",
  "description": "Drinks, Sodas, and juices"
}
```

---

### 2.5 Update Metadata Entry

Updates an existing entry. Supports partial updates.

- **Endpoint**: `PUT /catalog/meta/{type}/{code}`
- **Path Parameters**: `type`, `code`

#### Request Body
```json
{
  "name": "Dairy & Alternatives",
  "brands": ["AMUL", "NESTLE", "OATLY"]
}
```

---

### 2.6 Delete Metadata Entry

Deletes a catalog metadata entry.

- **Endpoint**: `DELETE /catalog/meta/{type}/{code}`
- **Response**: `204 No Content`

---

### 2.7 Get Catalog Tree

Retrieves a hierarchical tree view of the catalog metadata.

- **Endpoint**: `GET /catalog/meta/tree`
- **Query Parameters**:
    - `rootType`: (Optional) The type to use as the root of the tree. Default is `GROUP`.
    - `rootCode`: (Optional) Filter the tree to only show branches starting from this specific code.
- **Logic**:
    - The API returns a list of nested nodes.
    - Each node contains its `type`, `code`, `name`, `brands` (list), and a list of `children`.
    - Typical hierarchy: `GROUP` -> `CATEGORY` -> `SUBCATEGORY`.
    - `BRAND` items are also included if they have a `parentType` and `parentCode` linking them into the hierarchy.

#### Example Response
```json
[
  {
    "type": "GROUP",
    "code": "FOO",
    "name": "Foo Group",
    "brands": [],
    "children": [
      {
        "type": "CATEGORY",
        "code": "BAR",
        "name": "Bar Category",
        "brands": [],
        "children": []
      }
    ]
  }
]
```
