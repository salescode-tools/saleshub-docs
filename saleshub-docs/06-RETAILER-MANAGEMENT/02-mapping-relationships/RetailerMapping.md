# Create
curl -X POST http://localhost:8080/retailer-maps \
-H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" \
-d '{"outletCode":"OUT001","distributorCode":"DIST001","salesrepCode":"SR001","active":true,"extendedAttr":{"beat":"B1"}}'

# Bulk
curl -X POST http://localhost:8080/retailer-maps/bulk \
-H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" \
-d '{"items":[{"outletCode":"OUT002","distributorCode":"DIST009"},{"outletCode":"OUT003","salesrepCode":"SR007"}]}'

# List
curl "http://localhost:8080/retailer-maps?outlet_code=OUT001&active=true" -H "Authorization: Bearer $TOKEN"

# Get
curl http://localhost:8080/retailer-maps/1 -H "Authorization: Bearer $TOKEN"

# Update
curl -X PUT http://localhost:8080/retailer-maps/1 \
-H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" \
-d '{"outletCode":"OUT001","distributorCode":"DIST001","salesrepCode":"SR002","active":true,"extendedAttr":{"beat":"B2"}}'

# Delete
curl -X DELETE http://localhost:8080/retailer-maps/1 -H "Authorization: Bearer $TOKEN"
