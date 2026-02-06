curl -X POST "http://localhost:8080/org/location-defs" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-d '{"code":"COUNTRY","name":"Country","level":"COUNTRY","parents":null}'

# ZONE
curl -X POST "http://localhost:8080/org/location-defs" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-d '{"code":"ZONE","name":"Zone","level":"ZONE","parents":["COUNTRY"]}'

# STATE
curl -X POST "http://localhost:8080/org/location-defs" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-d '{"code":"STATE","name":"State","level":"STATE","parents":["ZONE"]}'

# DISTRICT
curl -X POST "http://localhost:8080/org/location-defs" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-d '{"code":"DISTRICT","name":"District","level":"DISTRICT","parents":["STATE"]}'

# CITY
curl -X POST "http://localhost:8080/org/location-defs" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-d '{"code":"CITY","name":"City","level":"CITY","parents":["DISTRICT"]}'

# PINCODE
curl -X POST "http://localhost:8080/org/location-defs" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-d '{"code":"PINCODE","name":"Pincode","level":"PINCODE","parents":["CITY"]}'

# LOCALITY
curl -X POST "http://localhost:8080/org/location-defs" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-d '{"code":"LOCALITY","name":"Locality","level":"LOCALITY","parents":["PINCODE"]}'


curl "http://localhost:8080/org/location-defs" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json" 