4) OpenAPI (summary)

POST /targets → upsert single (TargetUpsertReq) → {id}

PATCH /targets/{id} → partial update (TargetPatchReq) → {count}

DELETE /targets/{id} → {count}

POST /targets/search → (TargetSearchReq) → TargetDTO[]

POST /targets/bulk/upsert → (BulkUpsertReq) → {count}

POST /targets/bulk/patch → (BulkPatchReq) → {count}

POST /targets/bulk/delete → (BulkDeleteReq) → {count}

5) cURL quickies
# Upsert one (USER daily static)
curl -X POST http://localhost:8080/targets \
-H 'Content-Type: application/json' \
-d '{
"metric":"SALES_AMOUNT","level":"USER","username":"sr.ajay",
"periodKind":"DAILY","periodDate":"2025-11-05",
"staticValue":12000,"selection":"STATIC","status":"ACTIVE",
"code":"NOV_W1","name":"Week 1 Nov","tags":["NOV","W1"]
}'

# Search
curl -X POST http://localhost:8080/targets/search \
-H 'Content-Type: application/json' \
-d '{"level":"USER","metric":"SALES_AMOUNT","periodKind":"DAILY","fromDate":"2025-11-01","toDate":"2025-11-30","page":1,"pageSize":100}'

# Bulk upsert (mix of USER/OUTLET; ML rows too)
curl -X POST http://localhost:8080/targets/bulk/upsert \
-H 'Content-Type: application/json' \
-d '{"items":[
{"metric":"SALES_UNITS","level":"OUTLET","outletCode":"OUT001","periodKind":"MONTHLY","periodDate":"2025-11-01","mlValue":1500,"mlConfidence":90,"selection":"ML","status":"ACTIVE"},
{"metric":"SALES_AMOUNT","level":"USER","username":"sr.anu","periodKind":"DAILY","periodDate":"2025-11-10","staticValue":8000,"selection":"STATIC"}
]}'

# Bulk patch: change selection to ML where ML exists for a slice
curl -X POST http://localhost:8080/targets/bulk/patch \
-H 'Content-Type: application/json' \
-d '{
"where":[
{"metric":"SALES_UNITS","level":"OUTLET","outletCode":"OUT001","distributor":"","periodKind":"MONTHLY","periodDate":"2025-11-01"}
],
"patch":{"selection":"ML","status":"ACTIVE"}
}'

# Bulk delete by filter (cleanup a range)
curl -X POST http://localhost:8080/targets/bulk/delete \
-H 'Content-Type: application/json' \
-d '{"metric":"SALES_AMOUNT","level":"USER","fromDate":"2025-11-01","toDate":"2025-11-30","periodKind":"DAILY"}'
