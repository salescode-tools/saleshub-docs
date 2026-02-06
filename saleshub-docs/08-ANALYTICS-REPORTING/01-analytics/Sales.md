curl -X POST http://localhost:8080/sales/batch/fast \
-H 'Content-Type: application/json' \
-d '{
"sales":[
{
"clientRef":"a1",
"orderNumber":"SO-1001",
"outletCode":"OUT-001",
"salesrep":"sr.ajay",
"invoicedAt":"2025-10-31T10:30:00Z",
"extendedAttr":{"promo":"DIWALI25"},
"lines":[
{"sku":"SKU-5STAR-45G","distributor":"DIST-KOCHI-01","uom":"UNIT","qtyPieces":10,"unitPrice":12.5},
{"sku":"SKU-PERK-25G","distributor":"DIST-KOCHI-01","uom":"UNIT","qtyPieces":5,"unitPrice":8.0}
]
},
{
"clientRef":"a2",
"orderNumber":"SO-1002",
"outletCode":"OUT-002",
"salesrep":null,
"lines":[{"sku":"SKU-LAYS-52G","distributor":"DIST-KOCHI-01","uom":"UNIT","qtyPieces":12,"unitPrice":20.0}]
}
]
}'


curl -X PUT http://localhost:8080/sales/batch/fast \
-H 'Content-Type: application/json' \
-d '{
"sales":[
{ "id":101, "total":null, "lines":[
{"sku":"SKU-5STAR-45G","distributor":"DIST-KOCHI-01","uom":"UNIT","qtyPieces":12,"unitPrice":12.5},
{"sku":"SKU-PERK-25G","distributor":"DIST-KOCHI-01","uom":"UNIT","qtyPieces":6,"unitPrice":8.0}
]
},
{ "id":102, "invoicedAt":"2025-11-01T09:00:00+05:30", "lines":[] }
]
}'


GET /sales?month=2025-10&sku=SKU-5STAR-45G&distributor=DIST-KOCHI-01&limit=200
