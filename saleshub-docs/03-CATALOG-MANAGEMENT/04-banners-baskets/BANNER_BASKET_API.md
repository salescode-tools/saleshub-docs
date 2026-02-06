# Banner and Basket API Documentation

This document details the APIs for managing Banners and Baskets in the SalesCode Lite application.

## 1. Banners

Banners are displayed on the mobile app/portal and can link to various targets (Products, Schemes, External URLs, or Baskets).

### Data Model (`BannerDTO`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Unique UUID (auto-generated) |
| `title` | String | Display title of the banner |
| `imageUrl` | String | URL of the banner image |
| `videoUrl` | String | (Optional) URL of the banner video |
| `type` | String | Type of banner: `PRODUCT_LINK`, `SCHEME_LINK`, `COMMUNICATION`, `BASKET_LINK` |
| `targetConfig` | JSON | Configuration specific to the banner type |
| `groupName` | String | Optional group name for categorization (e.g. `HOME_PAGE`) |
| `tags` | List<String> | Optional tags for flexible filtering (e.g. `["summer", "sale"]`) |
| `sortOrder` | Integer | Display order (lower numbers first) |
| `active` | Boolean | Whether the banner is visible |
| `tenantId` | String | ID of the tenant owning this banner |

### 1.1 List Active Banners

Retrieves all active banners, sorted by `sortOrder`. Supports filtering by group and tags.

- **Endpoint**: `GET /banners`
- **Query Params**:
  - `group` (optional): Filter banners by a specific `groupName`.
  - `tags` (optional): Filter banners containing ANY of the specified tags.
  - `hierarchical` (optional, default: **true**): Aggregates banners from all child tenants.
- **Response**: `List<BannerDTO>`
- **Example**: `GET /banners?group=HOME_PAGE&tags=summer`

### 1.2 Get Unique Banner Tags

Retrieves a list of all unique tags currently used across all banners.

- **Endpoint**: `GET /banners/tags`
- **Response**: `List<String>`
- **Example**: `["summer", "sale", "new_arrival"]`

### 1.3 Create Banner

Creates a new banner.

- **Endpoint**: `POST /banners`
- **Body**: `BannerDTO`

#### Example: Communication Linked Banner (External Link)
Opens an external URL in a browser or web view.
```json
{
  "title": "Visit Website",
  "imageUrl": "https://s3.amazonaws.com/bucket/web_banner.jpg",
  "type": "COMMUNICATION",
  "targetConfig": {
    "subType": "EXTERNAL_LINK",
    "url": "https://www.salescode.ai"
  },
  "sortOrder": 1,
  "active": true
}
```

#### Example: Communication Linked Banner (Video)
Plays a video within the app.
```json
{
  "title": "Brand Story",
  "imageUrl": "https://s3.amazonaws.com/bucket/banner_image.jpg",
  "videoUrl": "https://s3.amazonaws.com/bucket/intro_video.mp4",
  "type": "COMMUNICATION",
  "targetConfig": {
    "subType": "VIDEO",
    "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  },
  "sortOrder": 2,
  "active": true
}
```

#### Example: Basket Linked Banner
Navigates the user to a specific product basket (e.g., Seasonal Offers).
```json
{
  "title": "Hot Sellers",
  "imageUrl": "https://s3.amazonaws.com/bucket/hot_sellers.jpg",
  "type": "BASKET_LINK",
  "targetConfig": {
    "basketId": "550e8400-e29b-41d4-a716-446655440000"
  },
  "sortOrder": 3,
  "active": true
}
```

#### Example: Product Linked Banner (List of SKUs)
Navigates the user to a product listing page filtered by the specified SKUs.
```json
{
  "title": "Featured Products",
  "imageUrl": "https://s3.amazonaws.com/bucket/product_banner.jpg",
  "type": "PRODUCT_LINK",
  "targetConfig": {
    "skus": ["PROD-12345", "PROD-67890"]
  },
  "sortOrder": 4,
  "active": true
}
```

#### Example: Communication Linked Banner (Document ID)
Opens a specific document (PDF, Image) stored in the system.
```json
{
  "title": "Product Catalog",
  "imageUrl": "https://s3.amazonaws.com/bucket/catalog_banner.jpg",
  "type": "COMMUNICATION",
  "targetConfig": {
    "subType": "DOCUMENT_ID",
    "documentId": "123e4567-e89b-12d3-a456-426614174000"
  },
  "sortOrder": 5,
  "active": true
}
```

#### Example: Banner with Group and Tags
Categorized banner for a specific section of the app.
```json
{
  "title": "Summer Clearance",
  "imageUrl": "https://s3.amazonaws.com/bucket/summer_sale.jpg",
  "type": "COMMUNICATION",
  "targetConfig": {
    "subType": "EXTERNAL_LINK",
    "url": "https://www.salescode.ai/clearance"
  },
  "groupName": "PROMOS",
  "tags": ["summer", "sale", "clearance"],
  "sortOrder": 6,
  "active": true
}
```

### 1.4 Bulk Create/Update Banners

Performs a batch upsert of banners. If a banner with the same title exists (per tenant), it is updated; otherwise, a new UUID is generated and the banner is created.

- **Endpoint**: `POST /banners/bulk`
- **Bulk Validation**: Every banner in the list is validated before execution. If any banner fails validation (e.g., invalid `basketId` or missing `type`), the entire request returns a `400 Bad Request`.

#### Example Request
```json
[
  {
    "title": "Summer Sale 2025",
    "imageUrl": "https://cdn.example.com/summer.jpg",
    "type": "COMMUNICATION",
    "targetConfig": {
      "subType": "EXTERNAL_LINK",
      "url": "https://example.com/sale"
    },
    "sortOrder": 1,
    "active": true
  },
  {
    "title": "New iPhone Arrival",
    "imageUrl": "https://cdn.example.com/iphone.jpg",
    "type": "PRODUCT_LINK",
    "targetConfig": {
      "skus": ["IPHONE-15", "IPHONE-15-PRO"]
    },
    "sortOrder": 2,
    "active": true
  }
]
```

#### Example Response
Returns the full list of created or updated banners, including their `id` and `tenantId`.
```json
[
  {
    "id": "76e338c2-497b-4861-825e-5874254f15d9",
    "tenantId": "my_tenant",
    "title": "Summer Sale 2025",
    "imageUrl": "https://cdn.example.com/summer.jpg",
    "type": "COMMUNICATION",
    "targetConfig": { "subType": "EXTERNAL_LINK", "url": "https://example.com/sale" },
    "sortOrder": 1,
    "active": true
  },
  {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "tenantId": "my_tenant",
    "title": "New iPhone Arrival",
    "imageUrl": "https://cdn.example.com/iphone.jpg",
    "type": "PRODUCT_LINK",
    "targetConfig": { "skus": ["IPHONE-15", "IPHONE-15-PRO"] },
    "sortOrder": 2,
    "active": true
  }
]
```

### 1.5 Update Banner

Updates an existing banner.

- **Endpoint**: `PUT /banners/{id}`
- **Path Params**: `id` (UUID)
- **Body**: `BannerDTO` (Partial updates allowed)

### 1.6 Delete Banner

Deletes a banner.

- **Endpoint**: `DELETE /banners/{id}`
- **Path Params**: `id` (UUID)

---

## 2. Baskets

Baskets are dynamic collections of products defined by rules (Tags, Recommendations, Schemes).

### Data Model (`BasketDTO`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Unique UUID (auto-generated) |
| `name` | String | Display name of the basket |
| `type` | String | Type of basket: `PRODUCT_TAG`, `RECOMMENDATION`, `SCHEME` |
| `config` | JSON | Configuration specific to the basket type |
| `tags` | List<String> | Optional tags for flexible filtering |
| `active` | Boolean | Whether the basket is active |
| `tenantId` | String | ID of the tenant owning this basket |

### 2.1 List Baskets

Retrieves all baskets.

- **Endpoint**: `GET /baskets`
- **Query Params**:
  - `hierarchical` (optional, default: **true**): Aggregates baskets from all child tenants.
- **Response**: `List<BasketDTO>`

### 2.2 Get Unique Basket Tags

Retrieves a list of all unique tags currently used across all baskets.

- **Endpoint**: `GET /baskets/tags`
- **Response**: `List<String>`
- **Example**: `["fmcg", "staples", "premium"]`

### 2.3 Create Basket

Creates a new basket.

- **Endpoint**: `POST /baskets`
- **Body**: `BasketDTO`

#### Example: Product Tag Basket
Resolves products that have *any* of the specified tags in their `tags` column.
```json
{
  "name": "New Launches",
  "type": "PRODUCT_TAG",
  "config": {
    "tags": ["new", "launch", "summer-2025"]
  },
  "active": true
}
```

#### Example: Recommendation Basket
Resolves products recommended for the specific outlet calling the API. Can optionally filter by tags (UPSELL, CROSS_SELL, etc.).
```json
{
  "name": "Recommended for You",
  "type": "RECOMMENDATION",
  "config": {
    "tags": ["UPSELL", "CROSS_SELL", "REGULAR"]
  },
  "active": true
}
```

#### Example: Promotion Basket (Single ID)
Resolves products eligible for a specific promotion.
```json
{
  "name": "Diwali Offer Products",
  "type": "PROMOTION",
  "config": {
    "promotionId": 12345
  },
  "active": true
}
```

#### Example: Promotion Basket (Multiple IDs - Comma Separated)
Resolves products eligible for any of the comma-separated promotion IDs.
```json
{
  "name": "Mega Sale Products",
  "type": "PROMOTION",
  "config": {
    "promotionId": "101, 102, 105"
  },
  "active": true
}
```

#### Example: Promotion Basket (Multiple IDs - Array)
Resolves products eligible for any of the promotion IDs in the array.
```json
{
  "name": "Combo Offer Products",
  "type": "PROMOTION",
  "config": {
    "promotionId": [201, 202, 203]
  },
  "active": true
}
```

### 2.4 Get Basket Products

Resolves and retrieves the actual products for a given basket.

- **Endpoint**: `GET /baskets/{id}/products`
- **Query Params**:
    - `outletCode`: Required for `RECOMMENDATION` type baskets.
- **Response**: `List<Product>`

### 2.5 Update Basket

Updates an existing basket.

- **Endpoint**: `PUT /baskets/{id}`
- **Path Params**: `id` (UUID)
- **Body**: `BasketDTO`

### 2.6 Delete Basket

Deletes a basket.

- **Endpoint**: `DELETE /baskets/{id}`
- **Path Params**: `id` (UUID)
