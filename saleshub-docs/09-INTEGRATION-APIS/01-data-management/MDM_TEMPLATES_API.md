# MDM Templates API

The MDM Templates API allows users to discover and download CSV templates for various master data entities. These templates contain the canonical headers required for data ingestion.

## Base URL
`/mdm/template`

---

## 1. List Supported Templates

Retrieves a list of all supported template types and their corresponding column headers.

### Request
- **Method**: `GET`
- **URL**: `/mdm/template`
- **Headers**: `Accept: application/json`

### Response
- **Status**: `200 OK`
- **Body**: JSON array of template definitions.

#### Example Response
```json
[
  {
    "type": "PRODUCT",
    "columns": [
      "skucode",
      "name",
      "brand",
      "category",
      "subcategory",
      "uom",
      "units_per_case",
      "price_num",
      "mrp_num",
      "image"
    ]
  },
  {
    "type": "OUTLET",
    "columns": [
      "outletcode",
      "name",
      "address",
      "phone",
      "email",
      "pincode",
      "outlet_division",
      "route_code",
      "city",
      "state",
      "country",
      "outlet_type",
      "outlet_category",
      "outlet_class",
      "sub_channel",
      "latitude",
      "longitude"
    ]
  },
  {
    "type": "DISTRIBUTOR",
    "columns": [
      "distributor_code",
      "distributor_name",
      "phone",
      "email",
      "address",
      "salesrep_count"
    ]
  },
  {
    "type": "SALESREP",
    "columns": [
      "distributor_code",
      "distributor_name",
      "salesrep_code",
      "salesrep_name",
      "phone",
      "email",
      "address"
    ]
  },
  {
    "type": "SALES",
    "columns": [
      "sub_channel",
      "channel",
      "piece_quantity",
      "case_quantity",
      "skucode",
      "sku_name",
      "net_amount",
      "loginid",
      "outletcode",
      "outlet_name",
      "creation_time",
      "invoice_number",
      "order_number",
      "distributor_code",
      "brand",
      "category",
      "subcategory",
      "lat",
      "lon"
    ]
  },
  {
    "type": "MOTHER_CODES",
    "columns": [
      "mothercode",
      "skucode"
    ]
  },
  {
    "type": "PRICING",
    "columns": [
      "skucode",
      "outletcode",
      "salesrep_code",
      "distributor_code",
      "scope",
      "price_unit",
      "price_case",
      "price_piece",
      "min_units",
      "min_cases",
      "min_pieces",
      "start_date",
      "end_date"
    ]
  },
  {
    "type": "SELL_ENTITLEMENT",
    "columns": [
      "skucode",
      "distributor_code",
      "salesrep_code",
      "moq_units",
      "lead_time_days",
      "active"
    ]
  }
]
```

---

## 2. Download Template

Downloads a CSV file template for a specific entity type.

### Request
- **Method**: `GET`
- **URL**: `/mdm/template/{type}`
- **Headers**: `Accept: application/octet-stream` (optional, browser handles download)

### Path Parameters
| Parameter | Type   | Description |
|-----------|--------|-------------|
| `type`    | String | The entity type to download. Case-insensitive. |

### Supported Types
- `PRODUCT`
- `OUTLET`
- `DISTRIBUTOR`
- `SALESREP`
- `SALES`
- `MOTHER_CODES`
- `PRICING`
- `SELL_ENTITLEMENT`

### Response
- **Status**: `200 OK`
- **Headers**: 
    - `Content-Type: application/octet-stream`
    - `Content-Disposition: attachment; filename="{type}_template.csv"`
- **Body**: CSV file content with headers.

#### Example Request
`GET /mdm/template/product`

#### Example Response Body (product_template.csv)
```csv
skucode,name,brand,category,subcategory,uom,units_per_case,price_num,mrp_num,image
```

### Errors
- **400 Bad Request**: If the `type` parameter is invalid.
- **404 Not Found**: If the template definition for the valid type is missing (should not happen for supported types).
