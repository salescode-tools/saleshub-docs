# FAQ Bulk Import Guide

## Overview

The FAQ bulk import feature allows you to import multiple FAQs at once using CSV files. This is useful for:
- Initial setup with existing FAQ data
- Bulk updates from external sources
- Migration from other systems

## Endpoints

### 1. Download CSV Template

**GET** `/faqs/template`

Downloads a CSV template with sample data.

**Response:**
CSV file with headers and example rows.

**cURL Example:**
```bash
curl -X GET http://localhost:8080/faqs/template \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -o faq_template.csv
```

---

### 2. Import FAQs from CSV

**POST** `/faqs/import`

Upload a CSV file to bulk import FAQs.

**Request:**
- Content-Type: `text/csv` or `application/octet-stream`
- Body: CSV file content

**Response:**
```json
{
  "success": 45,
  "failed": 5,
  "total": 50,
  "errors": [
    "Line 3: category is required",
    "Line 7: summary is required",
    "Line 12: Invalid category value"
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

---

## CSV Format

### Required Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| category | String | High-level category | `Product` |
| subcategory | String | Specific subcategory | `Pricing` |
| summary | String | Brief question/title | `How to calculate pricing?` |
| details | String | Detailed answer | `Use the pricing calculator...` |

### Optional Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| tags | String (comma-separated) | Topic tags | `pricing,calculator,api` |
| documentText | String | Full document content | `Complete documentation...` |
| documentUrl | String | External doc URL | `https://docs.example.com/pricing` |
| relatedFaqIds | String (comma-separated) | Related FAQ IDs (UUIDs) | Leave empty for import |

### Sample CSV

```csv
category,subcategory,summary,details,tags,documentText,documentUrl,relatedFaqIds
Product,Pricing,"How to calculate pricing?","Use the pricing calculator at...","pricing,calculator,api","","https://docs.example.com/pricing",""
Technical,API,"How to authenticate?","Use JWT tokens in Authorization header...","api,auth,security","","",""
Support,Billing,"When is payment due?","Payment is due on the 1st of each month...","billing,payment","","",""
```

---

## Validation

Each row is validated before import:
- **Required fields** must be present and non-empty
- **Tags** are automatically trimmed and filtered
- **URLs** should be valid (if provided)
- **Related FAQs** must exist (leave empty on initial import)

---

## Error Handling

- **Partial Success**: System imports valid rows even if some fail
- **Line Numbers**: Errors include line numbers for easy debugging
- **Detailed Messages**: Each error includes the specific validation failure

---

## Best Practices

1. **Use Template**: Download template first to ensure correct format
2. **Test Small**: Import a few rows first to validate format
3. **UTF-8 Encoding**: Ensure CSV is UTF-8 encoded
4. **Quote Fields**: Use quotes for fields containing commas or newlines
5. **Review Errors**: Check error messages and fix failed rows
6. **Incremental Import**: Import in batches for large datasets

---

## Examples

### Example 1: Basic Import

```csv
category,subcategory,summary,details,tags,documentText,documentUrl,relatedFaqIds
Product,Features,"What features are included?","All plans include basic features like...","features,plans","","",""
Product,Pricing,"How much does it cost?","Pricing starts at $99/month for...","pricing,cost","","",""
```

### Example 2: With Documentation

```csv
category,subcategory,summary,details,tags,documentText,documentUrl,relatedFaqIds
Technical,API,"API authentication","Use JWT tokens for authentication","api,auth,jwt","To authenticate, include your JWT token in the Authorization header...","https://api.example.com/docs/auth",""
```

### Example 3: With Special Characters

```csv
category,subcategory,summary,details,tags,documentText,documentUrl,relatedFaqIds
Support,General,"How to contact support?","Email us at support@example.com, or call 1-800-SUPPORT","support,contact","","",""
Product,Features,"What's included?","Features include: analytics, reporting, and more","features","","",""
```

---

## Troubleshooting

### "category is required"
- Ensure the category column has a value for all rows
- Check for extra spaces or hidden characters

### "Failed to parse CSV"
- Verify file is valid CSV format
- Check for unescaped quotes
- Ensure UTF-8 encoding

### "Line X: validation failed"
- Review the specific line in your CSV
- Ensure all required fields are present
- Check for invalid characters

---

## Integration with Document Upload

You can combine FAQ import with document uploads:

1. **Upload documents** first using `/documents/upload`
2. **Get document IDs** from upload responses
3. **Use document URLs** in `documentUrl` column
4. **Or use document text** in `documentText` column
