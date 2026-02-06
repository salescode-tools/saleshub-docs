# MDM Upload API

The MDM Upload API allows for the bulk ingestion of master data via CSV files. It supports various entity types and handles large data volumes efficiently.

## Base URL
`/master/upload`

---

## 1. Multipart CSV Upload

Uploads a single CSV file for processing. The system automatically detects the entity type based on the CSV headers.

### Request
- **Method**: `POST`
- **URL**: `/master/upload/multipart`
- **Headers**: `Content-Type: multipart/form-data`
- **Query Parameters**:
    - `header` (optional): `true` if the CSV contains a header row (default: `true`).
    - `autoMasters` (optional): `true` to automatically create missing referenced masters (e.g., brands/categories) if supported (default: `false`).
    - `ignoreTopRows` (optional): Number of rows to skip at the top of the file before processing headers/data (default: `0`). Useful for files with metadata or multiple header rows.
    - `check` (optional): `true` to perform a dry-run. Returns identified entity type, detected columns, and a preview of the first 5 rows without persisting any data to the database (default: `false`).
    - `extendedAttrFields` (optional): A comma-separated list of raw CSV header names that should be captured as extended attributes (JSONB) for the destination entity. This is currently supported for **Product**, **Outlet**, **Distributor**, and **Salesrep** entities.

### Form Data
- **file**: The CSV file to upload.

### Supported Entity Types (Auto-detected via Headers)
The system identifies the data type by inspecting the columns in the first row.

| Entity Type | Identifying Headers (Subset) |
|---|---|
| **User** | `username`, `first_name`, `last_name`, `auth_type` |
| **Distributor** | `distributor_code`, `distributor_name` |
| **Outlet** | `outletcode`, `name`, `address` |
| **Product (SKU)** | `skucode`, `name`, `brand` |
| **Pricing** | `skucode`, `price_unit`, `scope` |
| **Promotion** | `promotion_code`, `kind`, `buy_sku`, `percent_off` |
| **Sell Entitlement** | `skucode`, `moq_units`, `lead_time_days` |
| **Retailer Map** | `outletcode`, `salesrep_code`, `distributor_code` |
| **Mother Code** | `mothercode`, `skucode` |
| **FAQ** | `category`, `subcategory`, `summary` |
| **Banner** | `title`, `image_url`, `type`, `sort_order` |
| **Basket** | `name`, `type`, `tags` |

### Response
- **Status**: `200 OK`
- **Body**: A summary of the processing results.

#### Example Response
```json
{
  "inserted": 50,
  "updated": 10,
  "inputCount": 60,
  "errors": []
}
```

### Error Handling
- Invalid files or I/O errors will return `400 Bad Request`.
- Data validation errors (e.g., missing mandatory fields) are logged, and the processing result will reflect failed counts.
