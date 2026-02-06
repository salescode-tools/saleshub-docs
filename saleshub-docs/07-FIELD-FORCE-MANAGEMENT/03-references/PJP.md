# 1) Create Beat
curl -X POST http://localhost:8080/beats \
-H 'Content-Type: application/json' \
-H "Authorization: Bearer $TOKEN" \
-d '{
"code":"KOCHI-02",
"name":"Kochi Beat 02",
"territory":"Kochi",
"active":true,
"extendedAttr":{"zone":"south"}
}'

# 2) Create PJP with outlets inline
curl -X POST http://localhost:8080/pjp \
-H 'Content-Type: application/json' \
-H "Authorization: Bearer $TOKEN" \
-d '{
"salesrep":"applicate",
"beatCode":"KOCHI-02",
"routeCode":"ROUTE-SOUTH-1",
"frequency":"MONTHLY",
"week1":[],
"week2":["FRI"],
"week3":[],
"week4":["FRI"],
"week5":[],
"week6":[],
"active":true,
"outlets":[
{"outletCode":"9001","sequenceNo":1},
{"outletCode":"9002","sequenceNo":2}
]
}'

# 3) Add/update outlets later (delete+insert logic)
curl -X PUT http://localhost:8080/pjp/123/outlets \
-H "Authorization: Bearer $TOKEN" \
-H 'Content-Type: application/json' \
-d '[
{"outletCode":"9003","sequenceNo":1},
{"outletCode":"9001","sequenceNo":2},
{"outletCode":"9002","sequenceNo":3}
]'

# 4) Generate plan (today)
curl -X POST "http://localhost:8080/visit-plan/generate?date=$(date +%F)" \
-H "Authorization: Bearer $TOKEN" 


# 5) List plan
curl "http://localhost:8080/visit-plan?date=2025-10-31&salesrep=applicate" \
-H "Authorization: Bearer $TOKEN"

# 6) Log visit
curl -X POST http://localhost:8080/visits \
-H "Authorization: Bearer $TOKEN"
-H 'Content-Type: application/json' \
-d '{
"planId": 4567,
"salesrep":"sr.ajay",
"outletId":9001,
"visitedAt":"2025-11-01T10:35:00Z",
"lat":9.981,
"lng":76.282,
"visitType":"IN_PERSON",
"remarks":"Order booked",
"extendedAttr":{"orderValue":12500}
}'

GET http://localhost:8080/visits?date=2025-10-31&salesrepUsername=sr.ajay&outletCode=OUT-KC-9001&limit=200&offset=0
GET http://localhost:8080/visits?month=2025-10&salesrepUsername=sr.ajay

# 7) Get unique beats and routes for a user
curl "http://localhost:8080/pjp/unique-values?salesrepUsername=applicate" \
-H "Authorization: Bearer $TOKEN"

# 8) Get Visit Status (Assigned Route + Attendance + Completion)
curl "http://localhost:8080/visit-plan/visit-status?salesrep=sr.ajay&date=2026-02-02" \
-H "Authorization: Bearer $TOKEN"
