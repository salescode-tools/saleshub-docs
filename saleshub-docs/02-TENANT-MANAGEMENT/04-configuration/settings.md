curl "http://localhost:8080/api/settings?feature=application" -H "Authorization: Bearer $TOKEN"
curl "http://localhost:8080/api/settings?feature=mdmsetup" -H "Authorization: Bearer $TOKEN"



curl -X PUT http://localhost:8080/api/settings \
-H "Content-Type: application/json" \
-H "X-Tenant-Id: tenant1" \
-d '{
"feature": "checkout",
"key": "enable_discount",
"valueType": "BOOLEAN",
"valueJson": true,
"description": "Enable discounts during checkout",
"isSecret": false,
"updatedBy": "admin"
}'
JSON setting
bash
Copy code
curl -X PUT http://localhost:8080/api/settings \
-H "Content-Type: application/json" \
-H "X-Tenant-Id: tenant1" \
-d '{
"feature": "catalog",
"key": "filters",
"valueType": "JSON",
"valueJson": { "brands": ["Nestle","Pepsico"] },
"description": "UI filter config",
"updatedBy": "admin"
}'
✅ Bulk upsert
bash
Copy code
curl -X PUT http://localhost:8080/api/settings/bulk \
-H "Content-Type: application/json" \
-H "X-Tenant-Id: tenant1" \
-d '[
{
"feature": "billing",
"key": "tax_rate",
"valueType": "NUMBER",
"valueJson": 0.18,
"description": "GST rate",
"updatedBy": "admin"
},
{
"feature": "billing",
"key": "invoice_prefix",
"valueType": "STRING",
"valueJson": "INV-",
"updatedBy": "admin"
}
]'
✅ Get a setting
bash
Copy code
curl -X GET "http://localhost:8080/api/settings/checkout/enable_discount" \
-H "X-Tenant-Id: tenant1"
Include secret values
bash
Copy code
curl -X GET "http://localhost:8080/api/settings/checkout/api_key?include_secrets=true" \
-H "X-Tenant-Id: tenant1"
✅ List settings
All
bash
Copy code
curl -X GET "http://localhost:8080/api/settings" \
-H "X-Tenant-Id: tenant1"
Filter by feature
bash
Copy code
curl -X GET "http://localhost:8080/api/settings?feature=billing" \
-H "X-Tenant-Id: tenant1"
Search by keyword
bash
Copy code
curl -X GET "http://localhost:8080/api/settings?q=tax" \
-H "X-Tenant-Id: tenant1"
Pagination + include secrets
bash
Copy code
curl -X GET "http://localhost:8080/api/settings?limit=20&offset=0&include_secrets=true" \
-H "X-Tenant-Id: tenant1"
✅ List distinct features
bash
Copy code
curl -X GET http://localhost:8080/api/settings/features \
-H "X-Tenant-Id: tenant1"
✅ Delete a setting
bash
Copy code
curl -X DELETE http://localhost:8080/api/settings/checkout/enable_discount \
-H "X-Tenant-Id: tenant1"
🚨 Secret Setting Example (masked by default)
bash
Copy code
curl -X PUT http://localhost:8080/api/settings \
-H "Content-Type: application/json" \
-H "X-Tenant-Id: tenant1" \
-d '{
"feature": "checkout",
"key": "payment_api_key",
"valueType": "STRING",
"valueJson": "sk_live_12345",
"isSecret": true,
"updatedBy": "admin"
}'
View masked
bash
Copy code
curl -X GET "http://localhost:8080/api/settings/checkout/payment_api_key" \
-H "X-Tenant-Id: tenant1"
View real value
bash
Copy code
curl -X GET "http://localhost:8080/api/settings/checkout/payment_api_key?include_secrets=true" \
-H "X-Tenant-Id: tenant1"