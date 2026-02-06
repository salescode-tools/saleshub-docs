# FAQ API Documentation

## Overview

The FAQ (Frequently Asked Questions) management system provides endpoints for creating, managing, and searching FAQs with support for:
- Hierarchical categorization (category + subcategory)
- Tags for topic indexing
- Document sources (text or URL)
- Related FAQ linking
- Multi-tenant support

## Base URL

```
/faqs
```

## Endpoints

### 1. List/Search FAQs

**GET** `/faqs`

Search and filter FAQs with pagination.

**Query Parameters:**
- `category` (optional) - Filter by category
- `subcategory` (optional) - Filter by subcategory
- `searchQuery` (optional) - Search in summary and details (case-insensitive)
- `tags` (optional) - Comma-separated tags (matches any)
- `isActive` (optional) - Filter by active status (true/false)
- `limit` (optional) - Results per page (default: 50, max: 1000)
- `offset` (optional) - Pagination offset (default: 0)

**Response:**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "tenantId": "tenant123",
      "category": "Product",
      "subcategory": "Pricing",
      "summary": "How to calculate pricing?",
      "details": "Detailed explanation...",
      "tags": ["pricing", "api", "calculation"],
      "documentText": null,
      "documentUrl": "https://docs.example.com/pricing",
      "isActive": true,
      "viewCount": 42,
      "createdByUserId": 10,
      "relatedFaqIds": ["650e8400-e29b-41d4-a716-446655440001", "750e8400-e29b-41d4-a716-446655440002"],
      "extendedAttr": {},
      "createdAt": "2025-12-14T10:00:00Z",
      "updatedAt": "2025-12-14T10:00:00Z"
    }
  ],
  "total": 150,
  "limit": 50,
  "offset": 0,
  "hasMore": true
}
```

---

### 2. Get FAQ by ID

**GET** `/faqs/{id}`

Retrieve a specific FAQ by ID. Automatically increments view count.

**Path Parameters:**
- `id` - FAQ ID

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "tenantId": "tenant123",
  "category": "Product",
  "subcategory": "Pricing",
  "summary": "How to calculate pricing?",
  "details": "Detailed explanation...",
  "tags": ["pricing", "api"],
  "documentText": "Full document content here...",
  "documentUrl": null,
  "isActive": true,
  "viewCount": 43,
  "createdByUserId": 10,
  "relatedFaqIds": ["650e8400-e29b-41d4-a716-446655440001", "750e8400-e29b-41d4-a716-446655440002"],
  "extendedAttr": {},
  "createdAt": "2025-12-14T10:00:00Z",
  "updatedAt": "2025-12-14T10:00:00Z"
}
```

**Error Responses:**
- `404 Not Found` - FAQ does not exist

---

### 3. Create FAQ

**POST** `/faqs`

Create a new FAQ entry.

**Request Body:**
```json
{
  "category": "Technical",
  "subcategory": "API",
  "summary": "How to authenticate API requests?",
  "details": "Use JWT tokens in the Authorization header. First obtain a token via the /auth/login endpoint...",
  "tags": ["api", "authentication", "jwt", "security"],
  "documentText": "Optional full document text content",
  "documentUrl": "https://docs.example.com/api/auth",
  "relatedFaqIds": ["650e8400-e29b-41d4-a716-446655440012", "650e8400-e29b-41d4-a716-446655440015"],
  "extendedAttr": {
    "author": "John Doe",
    "version": "1.0"
  }
}
```

**Required Fields:**
- `category` - High-level category
- `subcategory` - Specific subcategory
- `summary` - Brief question or title
- `details` - Detailed answer/explanation

**Optional Fields:**
- `tags` - Array of tags for topic indexing
- `documentText` - Full document content
- `documentUrl` - URL to external documentation
- `relatedFaqIds` - Array of related FAQ IDs
- `extendedAttr` - Additional metadata (JSONB)

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440025",
  "tenantId": "tenant123",
  "category": "Technical",
  "subcategory": "API",
  "summary": "How to authenticate API requests?",
  "details": "Use JWT tokens...",
  "tags": ["api", "authentication", "jwt", "security"],
  "documentText": "Optional full document text content",
  "documentUrl": "https://docs.example.com/api/auth",
  "isActive": true,
  "viewCount": 0,
  "createdByUserId": 10,
  "relatedFaqIds": ["650e8400-e29b-41d4-a716-446655440012", "650e8400-e29b-41d4-a716-446655440015"],
  "extendedAttr": {
    "author": "John Doe",
    "version": "1.0"
  },
  "createdAt": "2025-12-14T14:30:00Z",
  "updatedAt": "2025-12-14T14:30:00Z"
}
```

**Error Responses:**
- `400 Bad Request` - Validation error (missing required fields)

---

### 4. Update FAQ

**PUT** `/faqs/{id}`

Update an existing FAQ. Only provided fields are updated (partial update).

**Path Parameters:**
- `id` - FAQ ID

**Request Body (all fields optional):**
```json
{
  "category": "Updated Category",
  "subcategory": "Updated Subcategory",
  "summary": "Updated summary",
  "details": "Updated details",
  "tags": ["updated", "tags"],
  "documentText": "Updated document text",
  "documentUrl": "https://docs.example.com/updated",
  "isActive": false,
  "relatedFaqIds": ["550e8400-e29b-41d4-a716-446655440001", "650e8400-e29b-41d4-a716-446655440002", "750e8400-e29b-41d4-a716-446655440003"],
  "extendedAttr": {
    "version": "2.0"
  }
}
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440025",
  "tenantId": "tenant123",
  "category": "Updated Category",
  "summary": "Updated summary",
  ...
}
```

**Error Responses:**
- `400 Bad Request` - No updates provided
- `404 Not Found` - FAQ does not exist

---

### 5. Delete FAQ

**DELETE** `/faqs/{id}`

Soft delete an FAQ (sets `isActive = false`).

**Path Parameters:**
- `id` - FAQ ID

**Response:**
- `204 No Content` - Successfully deleted

**Error Responses:**
- `404 Not Found` - FAQ does not exist

---

### 6. Add Related FAQ

**POST** `/faqs/{id}/related/{relatedId}`

Create a symmetric relationship between two FAQs. Both directions are created automatically.

**Path Parameters:**
- `id` - Source FAQ ID
- `relatedId` - Related FAQ ID

**Response:**
- `204 No Content` - Relationship created

**Error Responses:**
- `400 Bad Request` - Trying to relate FAQ to itself
- `404 Not Found` - Source or related FAQ does not exist

---

### 7. Remove Related FAQ

**DELETE** `/faqs/{id}/related/{relatedId}`

Remove a symmetric relationship between two FAQs. Both directions are removed.

**Path Parameters:**
- `id` - Source FAQ ID
- `relatedId` - Related FAQ ID

**Response:**
- `204 No Content` - Relationship removed

**Error Responses:**
- `404 Not Found` - FAQ does not exist

---

### 8. Bulk Create FAQs (JSON)

**POST** `/faqs/bulk`

Create multiple FAQs at once using JSON array.

**Request Body:**
```json
[
  {
    "category": "Product",
    "subcategory": "Pricing",
    "summary": "How to calculate pricing?",
    "details": "Use the pricing calculator at...",
    "tags": ["pricing", "calculator", "api"],
    "documentUrl": "https://docs.example.com/pricing",
    "documentText": "Text info"

  },
  {
    "category": "Technical",
    "subcategory": "API",
    "summary": "How to authenticate?",
    "details": "Use JWT tokens in Authorization header...",
    "tags": ["api", "auth", "security"],
     "documentText": "Text info",
         "documentUrl": "https://docs.example.com/pricing",

  }
]
```

**Response:**
```json
{
  "success": 45,
  "failed": 5,
  "total": 50,
  "createdIds": [
    "550e8400-e29b-41d4-a716-446655440001",
    "650e8400-e29b-41d4-a716-446655440002"
  ],
  "errors": [
    "Item 3: category is required",
    "Item 7: summary is required"
  ]
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/faqs/bulk \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '[
    {
      "category": "Product",
      "subcategory": "Features",
      "summary": "What features are included?",
      "details": "All plans include...",
      "tags": ["features", "plans"]
    }
  ]'
```

---

### 9. Download CSV Template

**GET** `/faqs/template`

Download a CSV template for bulk FAQ import with sample data.

**Response:**
- Content-Type: `text/csv`
- File: `faq_template.csv`

**cURL Example:**
```bash
curl -X GET http://localhost:8080/faqs/template \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -o faq_template.csv
```

---

### 10. Bulk Import FAQs (CSV)

**POST** `/faqs/import`

Import multiple FAQs from a CSV file.

**Request:**
- Content-Type: `text/csv` or `application/octet-stream`
- Body: CSV file content

**CSV Format:**
```
category,subcategory,summary,details,tags,documentText,documentUrl,relatedFaqIds
Product,Pricing,"How to calculate?","Details...","pricing,api","","https://docs...",""
```

**Response:**
```json
{
  "success": 45,
  "failed": 5,
  "total": 50,
  "errors": [
    "Line 3: category is required",
    "Line 7: summary is required"
  ]
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/faqs/import \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \ 
  -H 'Content-Type: text/csv' \
  --data-binary '@faqs.csv'
```

**Note:** See [FAQ_BULK_IMPORT.md](./FAQ_BULK_IMPORT.md) for complete bulk import guide.

---

## cURL Examples

### Create FAQ with tags and document URL

```bash
curl -X POST http://localhost:8080/api/faqs \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -d '{
    "category": "Technical",
    "subcategory": "API",
    "summary": "How to authenticate API requests?",
    "details": "Use JWT tokens in the Authorization header. Obtain tokens via /auth/login endpoint.",
    "tags": ["api", "authentication", "jwt"],
    "documentUrl": "https://docs.example.com/api/auth",
    "relatedFaqIds": []
  }'
```

### Search FAQs by category and tags

```bash
curl -X GET 'http://localhost:8080/api/faqs?category=Technical&tags=api,security&limit=20' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

### Search with text query

```bash
curl -X GET 'http://localhost:8080/api/faqs?searchQuery=authentication&isActive=true' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

### Get specific FAQ

```bash
curl -X GET http://localhost:8080/api/faqs/25 \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

### Update FAQ tags

```bash
curl -X PUT http://localhost:8080/api/faqs/25 \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -d '{
    "tags": ["api", "oauth", "authentication", "updated"]
  }'
```

### Update FAQ status (deactivate)

```bash
curl -X PUT http://localhost:8080/api/faqs/25 \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -d '{
    "isActive": false
  }'
```

### Add related FAQ link

```bash
curl -X POST http://localhost:8080/api/faqs/25/related/30 \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

### Remove related FAQ link

```bash
curl -X DELETE http://localhost:8080/api/faqs/25/related/30 \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

### Delete FAQ

```bash
curl -X DELETE http://localhost:8080/api/faqs/25 \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

### Filter by multiple criteria

```bash
curl -X GET 'http://localhost:8080/api/faqs?category=Product&subcategory=Pricing&tags=discount&searchQuery=calculate&isActive=true&limit=10&offset=0' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

---

## Features

### Tag-Based Filtering

Tags use PostgreSQL array overlap operator for efficient matching:
- Multiple tags are **OR** matched (any tag matches)
- Query: `?tags=api,security` returns FAQs with "api" **OR** "security" tags
- Tags are indexed with GIN for fast searches

### Related FAQs

- Symmetric relationships: Adding FAQ A → FAQ B automatically creates B → A
- Self-reference is prevented
- Cascade delete: Deleting an FAQ removes all its relationships

### Document Sources

FAQs support two document source options:
- **Document Text**: Full content stored in database (`documentText`)
- **Document URL**: Reference to external documentation (`documentUrl`)
- Both are optional and can be used independently or together

### View Tracking

- Automatic view count increment when FAQ is retrieved via GET `/faqs/{id}`
- Useful for popularity analytics

### Multi-Tenant Support

- All FAQs are tenant-scoped via Row-Level Security (RLS)
- `tenant_id` is automatically set from JWT token
- Users can only access FAQs from their tenant

---

## Common Use Cases

### 1. Browse All Active FAQs in a Category

```bash
GET /api/faqs?category=Technical&isActive=true&limit=50
```

### 2. Search for FAQs About Authentication

```bash
GET /api/faqs?searchQuery=authentication&tags=security,api
```

### 3. Create FAQ from External Documentation

```json
POST /api/faqs
{
  "category": "Integration",
  "subcategory": "Webhooks",
  "summary": "How to set up webhooks?",
  "details": "See complete guide at the link below.",
  "documentUrl": "https://docs.example.com/webhooks",
  "tags": ["webhooks", "integration", "api"]
}
```

### 4. Create FAQ with Full Content

```json
POST /api/faqs
{
  "category": "Troubleshooting",
  "subcategory": "Login",
  "summary": "Login fails with 'Invalid credentials'",
  "details": "This error occurs when...",
  "documentText": "Complete troubleshooting guide:\n\n1. Check username...\n2. Verify password...",
  "tags": ["login", "troubleshooting", "authentication"]
}
```

### 5. Link Related FAQs

```bash
# Create symmetric link between authentication FAQ and password reset FAQ
POST /api/faqs/12/related/15
```

### 6. Get Most Viewed FAQs

FAQs include `viewCount` - can be sorted client-side or enhanced with backend ordering.

---

## Data Model

### FAQ Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | Auto | Unique identifier (UUID) |
| tenantId | String | Auto | Tenant identifier (from JWT) |
| category | String | Yes | High-level category |
| subcategory | String | Yes | Specific subcategory |
| summary | String | Yes | Brief question/title |
| details | String | Yes | Detailed answer |
| tags | String[] | No | Tags for topic indexing |
| documentText | String | No | Full document content |
| documentUrl | String | No | External doc URL |
| isActive | Boolean | Auto | Active status (default: true) |
| viewCount | Long | Auto | View counter (default: 0) |
| createdByUserId | Long | Auto | Creator user ID |
| relatedFaqIds | String[] | No | Related FAQ IDs (UUIDs) |
| extendedAttr | Object | No | Additional metadata (JSONB) |
| createdAt | DateTime | Auto | Creation timestamp |
| updatedAt | DateTime | Auto | Last update timestamp |

---

## Error Codes

| Status Code | Description |
|-------------|-------------|
| 200 OK | Successful GET request |
| 201 Created | FAQ created successfully |
| 204 No Content | Successful DELETE or relationship operation |
| 400 Bad Request | Validation error or invalid request |
| 404 Not Found | FAQ not found |
| 500 Internal Server Error | Server error |

---

## Notes

- All date/time values are in ISO 8601 format with timezone
- Tags are case-sensitive strings
- Search queries use case-insensitive LIKE matching
- Maximum limit for search results: 1000
- Soft delete preserves data (use `isActive` filter to exclude deleted FAQs)
- Related FAQ IDs are always returned as a list (empty if none)
