curl -X POST http://localhost:8080/auth/register \
-H "Content-Type: application/json" \
-d '{
"tenantName":"Acme Corp",
"firstName":"Alice",
"lastName":"Admin",
"username":"alice.admin1",
"password":"Strong@123",
"email":"admin@acme.com",
"phone":"9876500000"
}'




curl -X POST http://localhost:8080/auth/login \
-H "Content-Type: application/json" \
-H "X-Tenant: t_e0a3e50fc793" \
-d '{"username":"alice.admin1","password":"Strong@123"}'

curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzYWxlc2RiLWF1dGgiLCJpYXQiOjE3NjE2Nzk3MzUsImV4cCI6MTc2MTcxNTczNSwidGVuYW50X2lkIjoidF9lMGEzZTUwZmM3OTMiLCJ1c2VyX2lkIjoxMywidXNlcm5hbWUiOiJhbGljZS5hZG1pbjEiLCJyb2xlcyI6WyJURU5BTlRfQURNSU4iXX0.HCOJzj8xQMHTcR-K4B7FRRtpRmjMMPUZ8MI4pxzbsZw" http://localhost:8080/outlets

curl -X POST http://localhost:8080/outlets \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{
"code":"OUT-2014",
"name":"Seaport Supermarket",
"users": [{
"firstName":"Raj",
"lastName":"Menon",
"password":"Strong@123",
"email":"raj@example.com",
"phone":"+91-98xxxxxxx"
}]
}'



curl -X POST http://localhost:8080/users \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{
"firstName":"Asha",
"lastName":"Nair",
"username":"asha.nair",
"password":"Strong@123",
"email":"asha@example.com",
"phone":"+91-98xxxxxxx"
}'

curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzYWxlc2RiLWF1dGgiLCJpYXQiOjE3NjE2Nzk3MzUsImV4cCI6MTc2MTcxNTczNSwidGVuYW50X2lkIjoidF9lMGEzZTUwZmM3OTMiLCJ1c2VyX2lkIjoxMywidXNlcm5hbWUiOiJhbGljZS5hZG1pbjEiLCJyb2xlcyI6WyJURU5BTlRfQURNSU4iXX0.HCOJzj8xQMHTcR-K4B7FRRtpRmjMMPUZ8MI4pxzbsZw" http://localhost:8080/users


curl -X POST http://localhost:8080/products \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{
"sku":"SKU-1001",
"name":"Cool Drink 500ml",
"brand":"FreshCo",
"category":"Beverages",
"unitsPerCase":24,
"mrpMinor":3500,
"active":true,
"extendedAttr":"{\"shelf\":\"A1\",\"tax\":\"GST18\"}"
}'


curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/products
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/products/sku/SKU-1001


curl -X POST http://localhost:8080/distributors \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{
"code":"D100",
"name":"Mega Distributors",
"address":"Main Road",
"lat":12.9716,
"lon":77.5946,
"extendedAttr":"{\"region\":\"South\",\"gst\":\"29ABCDE1234F1Z9\"}"
}'
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/distributors


curl -X POST http://localhost:8080/distributors \                        
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{
"code": "D101",
"name": "Bangalore Prime Distributors",
"address": "MG Road, Bangalore",
"lat": 12.9716,
"lon": 77.5946,
"extendedAttr": "{\"zone\":\"South\",\"tier\":\"A\"}",
"users": [
{
"firstName": "Ravi",
"lastName": "Kumar",
"username": "ravi.kumar",
"password": "Pass@123",
"email": "ravi@bpd.com",
"phone": "9876540001"
},
{
"firstName": "Asha",
"lastName": "Reddy",
"username": "asha.reddy",
"password": "Pass@123",
"email": "asha@bpd.com",
"phone": "9876540002"
}
]
}'


curl -X POST http://localhost:8080/orders \
-H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
-d  '{
"outletCode": "OUT-2042",
"salesrep": "rahul",
"distributor": "DIST-99",
"notes": "Ship today if possible",
"lines": [
{
"sku": "SKU-MILK-500ML",
"distributor": "DIST-99",
"uom": "UNIT",
"qtyCases": 1.50000,
"qtyPieces": 6.00000,
"unitPrice": 28.75000,
"lineUnits": 24.00000,
"discount": 10.00000,
"lineAmount": 680.00000,
"isFree": false,
"priceRuleId": 456,
"priceUomUsed": "UNIT",
"shape": "SALESREP",
"extendedAttr": "{\"batch\":\"B24-10\",\"temp\":\"cold\"}"
},
{
"sku": "SKU-COOKIES-200G",
"distributor": "DIST-99",
"uom": "UNIT",
"qtyCases": 0.00000,
"qtyPieces": 2.00000,
"unitPrice": 50.00000,
"lineUnits": 2.00000,
"discount": 100.00000,
"lineAmount": 100.00000,
"isFree": true,
"priceRuleId": null,
"priceUomUsed": "UNIT",
"shape": "SALESREP",
"extendedAttr": "{\"freeOfCharge\":true}"
}
]
}'

curl -X POST http://localhost:8080/price-rules \
-H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
-d '{
"productId": "SKU-123",
"outletCode": "OUT-10",
"distributor": "DIST-5",
"scope": "OUTLET_DISTRIBUTOR",
"priceUnit": 12.50000,
"priceCase": 600.00000,
"pricePiece": 1.50000,
"minUnits": 5.00000,
"minCases": 0,
"minPieces": 0,
"startOn": "2025-01-01",
"endOn": "2025-12-31",
"extendedAttr": "{\"promo\":\"NEW_YEAR\"}"
}'


curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/roles
curl -X POST http://localhost:8080/roles \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" \
-d '{
"name": "SALES_MANAGER",
"description": "Sales management & reporting role"
}'

curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/org-types


curl -X POST http://localhost:8080/org-types \
-H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
-d '{"code":"AREA","description":"Area unit","parents":["COMPANY","REGION"]}'


curl -X POST http://localhost:8080/outlet-activities \
-H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
-d '{
"outletCode": "OUT-2042",
"actorUserId": 42,
"actorUsername": "rahul",
"actorKind": "SALESREP",
"activityType": "CHECKIN",
"summary": "Reached store",
"payload": "{\"battery\":82,\"notes\":\"traffic\"}",
"clientTs": "2025-10-29T06:40:12Z",
"lat": 9.981, "lon": 76.282,
"source": "android",
"deviceId": "and-xyz-123"
}'
{"id":"2","outletCode":"OUT-2042","actorUserId":null,"actorUsername":"rahul","actorKind":"SALESREP","activityType":"CHECKIN","summary":"Reached store","payload":{"notes":"traffic","battery":82},"clientTs":"2025-10-29T06:40:12Z","occurredAt":"2025-10-29T06:40:12Z","recordedAt":"2025-10-29T14:35:17.368938Z","lat":9.981,"lon":76.282,"source":"android","deviceId":"and-xyz-123","activityDayUtc":"2025-10-29"}